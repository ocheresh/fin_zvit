import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/account.dart';
import 'package:fin/features/acoounts/mvi/account_viewmodel.dart';
import 'package:fin/features/acoounts/mvi/account_intent.dart';
import 'package:fin/features/acoounts/mvi/account_state.dart';
import 'package:fin/features/acoounts/ui/account_edit_screen.dart';

import 'widgets/breakpoints.dart';
import 'widgets/headers.dart';
import 'widgets/account_row.dart';
import 'widgets/account_card.dart';
import '../ui/accounts_export.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});
  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Map<String, bool> _filterOptions = {
    'accountNumber': true,
    'rozporiadNumber': true,
    'legalName': true,
    'edrpou': true,
    'subordination': true,
    'additionalInfo': true,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AccountViewModel>().onIntent(LoadAccountsIntent()),
    );
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.toLowerCase()),
    );
  }

  List<Account> _applyFilters(List<Account> all) {
    if (_query.isEmpty) return all;
    final q = _query;
    return all.where((a) {
      return (_filterOptions['accountNumber']! &&
              a.accountNumber.toLowerCase().contains(q)) ||
          (_filterOptions['rozporiadNumber']! &&
              a.rozporiadNumber.toLowerCase().contains(q)) ||
          (_filterOptions['legalName']! &&
              a.legalName.toLowerCase().contains(q)) ||
          (_filterOptions['edrpou']! && a.edrpou.toLowerCase().contains(q)) ||
          (_filterOptions['subordination']! &&
              (a.subordination ?? '').toLowerCase().contains(q)) ||
          (_filterOptions['additionalInfo']! &&
              a.additionalInfo.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> _onAdd() async {
    final res = await Navigator.push<Account?>(
      context,
      MaterialPageRoute(builder: (_) => const AccountEditScreen()),
    );
    if (res != null) {
      await context.read<AccountViewModel>().onIntent(AddAccountIntent(res));
    }
  }

  Future<void> _onEdit(Account a) async {
    final res = await Navigator.push<Account?>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountEditScreen(account: a, isEditing: true),
      ),
    );
    if (res != null) {
      await context.read<AccountViewModel>().onIntent(EditAccountIntent(res));
    }
  }

  Future<void> _onDelete(Account a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Видалити'),
        content: Text('Видалити ${a.accountNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ні'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Так', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await context.read<AccountViewModel>().onIntent(
        DeleteAccountIntent(a.id!),
      );
    }
  }

  void _showDetails(Account a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Деталі'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Особовий рахунок: ${a.accountNumber}'),
            Text('№ розпорядника: ${a.rozporiadNumber}'),
            Text('Найменування: ${a.legalName}'),
            Text('ЄДРПОУ: ${a.edrpou}'),
            Text('Підпорядкованість: ${a.subordination ?? '-'}'),
            Text(
              'Дод. інфо: ${a.additionalInfo.isEmpty ? '-' : a.additionalInfo}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccountViewModel>();
    final s = vm.state;

    if (s.status == LoadStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (s.status == LoadStatus.error) {
      return Scaffold(body: Center(child: Text('Помилка: ${s.error}')));
    }

    final accounts = _applyFilters(s.accounts);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final bp = Breakpoints.of(w);
        final scale = bp.scale;
        final pad = (12.0 * scale).clamp(8.0, 16.0);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Особові рахунки'),
            actions: [
              if (accounts.isNotEmpty)
                IconButton(
                  tooltip: 'Експорт у Excel',
                  icon: const Icon(Icons.print_outlined),
                  onPressed: () async {
                    final path = await exportAccountsToExcel(accounts);
                    final msg = path == null
                        ? 'Файл "accounts.xlsx" завантажено'
                        : 'Збережено: $path';
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    }
                  },
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => vm.onIntent(LoadAccountsIntent()),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _onAdd,
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(pad),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Пошук',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // content
              Expanded(
                child: accounts.isEmpty
                    ? const Center(child: Text('Рахунків не знайдено'))
                    : (bp.isSmall
                          ? ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: pad,
                                vertical: pad / 2,
                              ),
                              itemCount: accounts.length,
                              itemBuilder: (_, i) => AccountCard(
                                account: accounts[i],
                                scale: scale,
                                onTap: () => _showDetails(accounts[i]),
                                onEdit: () => _onEdit(accounts[i]),
                                onDelete: () => _onDelete(accounts[i]),
                              ),
                            )
                          : Column(
                              children: [
                                TableHeaders(scale: scale, bp: bp),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: accounts.length,
                                    itemBuilder: (_, i) => AccountRow(
                                      account: accounts[i],
                                      scale: scale,
                                      bp: bp,
                                      onTap: () => _showDetails(accounts[i]),
                                      onEdit: () => _onEdit(accounts[i]),
                                      onDelete: () => _onDelete(accounts[i]),
                                    ),
                                  ),
                                ),
                              ],
                            )),
              ),
            ],
          ),
        );
      },
    );
  }
}
