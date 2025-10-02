import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'account_edit_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Екран зі списком особових рахунків
class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late Future<List<Account>> _futureAccounts;
  final ApiService _apiService = ApiService("http://localhost:3000");
  List<Account> _filteredAccounts = [];
  List<Account> _allAccounts = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  /// Фільтри
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
    _loadAccounts();
    _searchController.addListener(_onSearchChanged);
  }

  /// Завантаження рахунків
  void _loadAccounts() {
    setState(() {
      _futureAccounts = _apiService.fetchAccounts().then((accounts) {
        _allAccounts = accounts;
        _applyFilters();
        return accounts;
      });
    });
  }

  /// Пошук
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredAccounts = List<Account>.from(_allAccounts);
      return;
    }
    final q = _searchQuery;
    _filteredAccounts = _allAccounts.where((a) {
      return (_filterOptions['accountNumber'] == true &&
              a.accountNumber.toLowerCase().contains(q)) ||
          (_filterOptions['rozporiadNumber'] == true &&
              a.rozporiadNumber.toLowerCase().contains(q)) ||
          (_filterOptions['legalName'] == true &&
              a.legalName.toLowerCase().contains(q)) ||
          (_filterOptions['edrpou'] == true &&
              a.edrpou.toLowerCase().contains(q)) ||
          (_filterOptions['subordination'] == true &&
              (a.subordination ?? '').toLowerCase().contains(q)) ||
          (_filterOptions['additionalInfo'] == true &&
              a.additionalInfo.toLowerCase().contains(q));
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged();
  }

  /// Експорт у Excel
  Future<void> exportAccountsToExcel(List<Account> accounts) async {
    final excel = ex.Excel.createExcel();
    final sheet = excel['Accounts'];

    sheet.appendRow([
      ex.TextCellValue("Особовий рахунок"),
      ex.TextCellValue("Номер розпорядника коштів"),
      ex.TextCellValue("Найменування"),
      ex.TextCellValue("ЄДРПОУ"),
      ex.TextCellValue("Підпорядкованість"),
      ex.TextCellValue("Додаткова інформація"),
    ]);

    for (final acc in accounts) {
      sheet.appendRow([
        ex.TextCellValue(acc.accountNumber),
        ex.TextCellValue(acc.rozporiadNumber),
        ex.TextCellValue(acc.legalName),
        ex.TextCellValue(acc.edrpou),
        ex.TextCellValue(acc.subordination ?? '-'),
        ex.TextCellValue(
          acc.additionalInfo.isNotEmpty ? acc.additionalInfo : "-",
        ),
      ]);
    }

    final fileBytes = excel.save(fileName: "accounts.xlsx")!;
    if (kIsWeb) {
      print("✅ Excel збережено (web)");
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/accounts.xlsx")
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      print("✅ Excel збережено: ${file.path}");
    }
  }

  /// --- Дії ---
  void _showSnackBar(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Детальна інформація'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Особовий рахунок: ${account.accountNumber}"),
            Text("Номер розпорядника коштів: ${account.rozporiadNumber}"),
            Text("Найменування: ${account.legalName}"),
            Text("ЄДРПОУ: ${account.edrpou}"),
            Text("Підпорядкованість: ${account.subordination ?? '-'}"),
            if (account.additionalInfo.isNotEmpty)
              Text("Додаткова інформація: ${account.additionalInfo}"),
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

  Future<void> _addAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountEditScreen()),
    );
    if (result is Map) {
      await _apiService.addAccount(result['ui'] as Account);
      _loadAccounts();
      _showSnackBar('Рахунок успішно додано');
    }
  }

  Future<void> _editAccount(Account account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountEditScreen(account: account, isEditing: true),
      ),
    );
    if (result is Map) {
      await _apiService.updateAccount(result['ui'] as Account);
      _loadAccounts();
      _showSnackBar('Рахунок успішно оновлено');
    }
  }

  Future<void> _deleteAccount(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Видалити рахунок'),
        content: Text(
          'Ви впевнені, що хочете видалити ${account.accountNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _apiService.deleteAccount(account.id!);
      _loadAccounts();
      _showSnackBar('Рахунок успішно видалено');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Особові рахунки'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async => exportAccountsToExcel(await _futureAccounts),
          ),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAccounts),
        ],
      ),
      body: Column(
        children: [
          /// Поле пошуку
          SearchField(
            controller: _searchController,
            onClear: _clearSearch,
            query: _searchQuery,
          ),
          Expanded(
            child: FutureBuilder<List<Account>>(
              future: _futureAccounts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final accounts = _searchQuery.isEmpty
                      ? snapshot.data!
                      : _filteredAccounts;
                  if (accounts.isEmpty)
                    return const Center(child: Text("Рахунків не знайдено"));

                  return AccountsTable(
                    accounts: accounts,
                    onView: _showAccountDetails,
                    onEdit: _editAccount,
                    onDelete: _deleteAccount,
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Помилка: ${snapshot.error}"));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// --- Віджети ---

/// Поле пошуку
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final String query;

  const SearchField({
    super.key,
    required this.controller,
    required this.onClear,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Пошук рахунків',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Таблиця з рахунками
class AccountsTable extends StatelessWidget {
  final List<Account> accounts;
  final Function(Account) onView;
  final Function(Account) onEdit;
  final Function(Account) onDelete;

  const AccountsTable({
    super.key,
    required this.accounts,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Особовий рахунок')),
          DataColumn(label: Text('№ розп-ка коштів')),
          DataColumn(label: Text('Найменування')),
          DataColumn(label: Text('ЄДРПОУ')),
          DataColumn(label: Text('Підпорядкованість')),
          DataColumn(label: Text('Додаткова інформація')),
          DataColumn(label: Text('Дії')),
        ],
        rows: accounts.map((account) {
          return DataRow(
            cells: [
              DataCell(Text(account.accountNumber)),
              DataCell(Text(account.rozporiadNumber)),
              DataCell(Text(account.legalName)),
              DataCell(Text(account.edrpou)),
              DataCell(Text(account.subordination ?? '-')),
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(
                    account.additionalInfo.isNotEmpty
                        ? account.additionalInfo
                        : "-",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                AccountActionsMenu(
                  account: account,
                  onView: onView,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Меню дій для рахунку
class AccountActionsMenu extends StatelessWidget {
  final Account account;
  final Function(Account) onView;
  final Function(Account) onEdit;
  final Function(Account) onDelete;

  const AccountActionsMenu({
    super.key,
    required this.account,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black87),
      onSelected: (value) {
        if (value == 'view') onView(account);
        if (value == 'edit') onEdit(account);
        if (value == 'delete') onDelete(account);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: ListTile(
            leading: Icon(Icons.visibility, color: Colors.blue),
            title: Text('Переглянути'),
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.green),
            title: Text('Редагувати'),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Видалити'),
          ),
        ),
      ],
    );
  }
}
