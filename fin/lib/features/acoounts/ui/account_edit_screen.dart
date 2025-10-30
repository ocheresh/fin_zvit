import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fin/core/api/api_service.dart';
import 'package:fin/core/models/account.dart';
import 'package:fin/core/config/app_config.dart';
import 'package:fin/features/acoounts/mvi/account_edit_viewmodel.dart';
import 'package:fin/features/acoounts/mvi/account_viewmodel.dart';

class AccountEditScreen extends StatelessWidget {
  final Account? account;
  final bool isEditing;

  const AccountEditScreen({super.key, this.account, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AccountEditViewModel(api: ApiService(AppConfig.apiBaseUrl))
            ..init(account),
      child: _AccountEditForm(isEditing: isEditing),
    );
  }
}

class _AccountEditForm extends StatefulWidget {
  final bool isEditing;
  const _AccountEditForm({required this.isEditing});

  @override
  State<_AccountEditForm> createState() => _AccountEditFormState();
}

class _AccountEditFormState extends State<_AccountEditForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _accountNumberController;
  late TextEditingController _rozporiadNumberController;
  late TextEditingController _legalNameController;
  late TextEditingController _edrpouController;
  late TextEditingController _subordinationController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AccountEditViewModel>();
    _accountNumberController = TextEditingController(
      text: vm.account?.accountNumber ?? '',
    );
    _rozporiadNumberController = TextEditingController(
      text: vm.account?.rozporiadNumber ?? '',
    );
    _legalNameController = TextEditingController(
      text: vm.account?.legalName ?? '',
    );
    _edrpouController = TextEditingController(text: vm.account?.edrpou ?? '');
    _subordinationController = TextEditingController(
      text: vm.account?.subordination ?? '',
    );
    _additionalInfoController = TextEditingController(
      text: vm.account?.additionalInfo ?? '',
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _rozporiadNumberController.dispose();
    _legalNameController.dispose();
    _edrpouController.dispose();
    _subordinationController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountEditViewModel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditing ? 'Редагувати рахунок' : 'Додати рахунок',
            ),
            backgroundColor: Colors.blue[700],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildField(
                    controller: _accountNumberController,
                    label: 'Особовий рахунок № *',
                    icon: Icons.account_balance,
                  ),

                  const SizedBox(height: 16),
                  _buildField(
                    controller: _rozporiadNumberController,
                    label: 'Номер розпорядника коштів *',
                    icon: Icons.format_list_numbered,
                  ),

                  const SizedBox(height: 16),
                  _buildField(
                    controller: _legalNameController,
                    label: 'Найменування *',
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _edrpouController,
                    label: 'ЄДРПОУ',
                    icon: Icons.receipt_long_sharp,
                    keyboard: TextInputType.number,
                    // Порожнє — ок (вставимо 00000000 при збереженні).
                    // Якщо користувач ввів щось — має бути 8 цифр.
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return null;
                      if (s.length != 8 || int.tryParse(s) == null) {
                        return 'Має бути 8 цифр';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildField(
                    controller: _subordinationController,
                    label: 'Підпорядкованість',
                    icon: Icons.account_tree,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _additionalInfoController,
                    label: 'Додаткова інформація',
                    icon: Icons.info_outline,
                    maxLines: 3,
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      // 1) Нормалізація + дефолти
                      final accountNumber = _accountNumberController.text
                          .trim();
                      final rozporiadNumber = _rozporiadNumberController.text
                          .trim();
                      final legalName = _legalNameController.text.trim();
                      final edrpouRaw = _edrpouController.text.trim();
                      final subordinationRaw = _subordinationController.text
                          .trim();
                      final additionalInfo = _additionalInfoController.text
                          .trim();

                      final edrpou = edrpouRaw.isEmpty ? '00000000' : edrpouRaw;
                      final subordination = subordinationRaw.isEmpty
                          ? 'Інше'
                          : subordinationRaw;

                      // 2) Перевірка унікальності (по локальному стану VM)
                      final list = context
                          .read<AccountViewModel>()
                          .state
                          .accounts;
                      final editingId = context
                          .read<AccountEditViewModel>()
                          .account
                          ?.id;

                      bool clashAccount = list.any(
                        (x) =>
                            x.accountNumber.toLowerCase() ==
                                accountNumber.toLowerCase() &&
                            x.id != editingId,
                      );

                      bool clashRozp = list.any(
                        (x) =>
                            x.rozporiadNumber.toLowerCase() ==
                                rozporiadNumber.toLowerCase() &&
                            x.id != editingId,
                      );

                      bool clashName = list.any(
                        (x) =>
                            x.legalName.toLowerCase() ==
                                legalName.toLowerCase() &&
                            x.id != editingId,
                      );

                      if (clashAccount || clashRozp || clashName) {
                        final reasons = <String>[];
                        if (clashAccount)
                          reasons.add('такий Особовий рахунок уже існує');
                        if (clashRozp)
                          reasons.add('такий № розпорядника коштів уже існує');
                        if (clashName)
                          reasons.add('таке Найменування вже існує');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(reasons.join('. '))),
                        );
                        return;
                      }

                      // 3) Будуємо модель і повертаємо
                      final vm = context.read<AccountEditViewModel>();
                      final acc = vm.buildAccount(
                        rozporiadNumber: rozporiadNumber,
                        accountNumber: accountNumber,
                        legalName: legalName,
                        edrpou: edrpou,
                        subordination: subordination,
                        additionalInfo: additionalInfo,
                      );

                      Navigator.pop(context, acc);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isEditing ? 'Зберегти зміни' : 'Додати рахунок',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator:
          validator ??
          (v) => v == null || v.trim().isEmpty ? 'Обов’язкове поле' : null,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
