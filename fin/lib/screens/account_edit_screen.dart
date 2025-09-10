import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountEditScreen extends StatefulWidget {
  final Account? account;
  final bool isEditing;

  const AccountEditScreen({super.key, this.account, this.isEditing = false});

  @override
  _AccountEditScreenState createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountNumberController;
  late TextEditingController _rozporiadNumberController;
  late TextEditingController _legalNameController;
  late TextEditingController _edrpouController;
  late TextEditingController _subordinationController;
  late TextEditingController _additionalInfoController; // Додано контролер

  @override
  void initState() {
    super.initState();
    _accountNumberController = TextEditingController(
      text: widget.isEditing ? widget.account?.accountNumber ?? '' : '',
    );
    _rozporiadNumberController = TextEditingController(
      text: widget.isEditing ? widget.account?.rozporiadNumber ?? '' : '',
    );
    _legalNameController = TextEditingController(
      text: widget.isEditing ? widget.account?.legalName ?? '' : '',
    );
    _edrpouController = TextEditingController(
      text: widget.isEditing ? widget.account?.edrpou ?? '' : '',
    );
    _subordinationController = TextEditingController(
      text: widget.isEditing ? widget.account?.subordination ?? '' : '',
    );
    _additionalInfoController = TextEditingController(
      // Ініціалізовано
      text: widget.isEditing ? widget.account?.additionalInfo ?? '' : '',
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _rozporiadNumberController.dispose();
    _legalNameController.dispose();
    _edrpouController.dispose();
    _subordinationController.dispose();
    _additionalInfoController.dispose(); // Додано dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Редагувати рахунок' : 'Додати рахунок'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Розпорядчий номер
              _buildFormField(
                controller: _rozporiadNumberController,
                labelText: 'Розпорядчий номер *',
                hintText: 'Введіть розпорядчий номер',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Обов\'язкове поле';
                  }
                  return null;
                },
                icon: Icons.numbers,
              ),
              const SizedBox(height: 16),

              // Особовий рахунок
              _buildFormField(
                controller: _accountNumberController,
                labelText: 'Особовий рахунок *',
                hintText: 'Введіть номер рахунку',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Обов\'язкове поле';
                  }
                  return null;
                },
                icon: Icons.account_balance,
              ),
              const SizedBox(height: 16),

              // Найменування
              _buildFormField(
                controller: _legalNameController,
                labelText: 'Найменування *',
                hintText: 'Введіть найменування',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Обов\'язкове поле';
                  }
                  return null;
                },
                icon: Icons.business,
              ),
              const SizedBox(height: 16),

              // ЄДРПОУ
              _buildFormField(
                controller: _edrpouController,
                labelText: 'ЄДРПОУ *',
                hintText: 'Введіть 8-значний код ЄДРПОУ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Обов\'язкове поле';
                  }
                  if (value.length != 8) {
                    return 'ЄДРПОУ має містити рівно 8 цифр';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Тільки цифри дозволені';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                icon: Icons.fingerprint,
              ),
              const SizedBox(height: 16),

              // Підпорядкованість
              _buildFormField(
                controller: _subordinationController,
                labelText: 'Підпорядкованість *',
                hintText: 'Введіть підпорядкованість',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Обов\'язкове поле';
                  }
                  return null;
                },
                icon: Icons.account_tree,
              ),
              const SizedBox(height: 16),

              // Додаткова інформація
              _buildFormField(
                controller: _additionalInfoController,
                labelText: 'Додаткова інформація',
                hintText: 'Введіть додаткову інформацію (не обов\'язково)',
                validator: (value) => null, // Не обов'язкове поле
                icon: Icons.info_outline,
                maxLines: 3, // Багаторядкове поле
              ),
              const SizedBox(height: 24),

              // Кнопка збереження
              ElevatedButton(
                onPressed: _saveAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  widget.isEditing ? 'Зберегти зміни' : 'Додати рахунок',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Додаткова інформація
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '* - обов\'язкові для заповнення поля',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Допоміжний метод для створення полів форми
  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue[700]) : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      maxLines: maxLines,
    );
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.isEditing
            ? widget.account!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        rozporiadNumber: _rozporiadNumberController.text,
        accountNumber: _accountNumberController.text,
        legalName: _legalNameController.text,
        edrpou: _edrpouController.text,
        subordination: _subordinationController.text,
        additionalInfo:
            _additionalInfoController.text, // Додано передачу параметра
      );

      Navigator.pop(context, account);
    }
  }
}
