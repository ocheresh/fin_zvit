import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'account_edit_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late Future<List<Account>> _futureAccounts;
  final ApiService _apiService = ApiService("http://localhost:3000");
  List<Account> _filteredAccounts = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Map<String, bool> _filterOptions = {
    'accountNumber': true,
    'rozporiadNumber': true,
    'legalName': true,
    'edrpou': true,
    'subordination': true,
    'additionalInfo': true,
  };

  final Map<String, String> _filterLabels = {
    "accountNumber": "Особовий рахунок",
    "rozporiadNumber": "Номер розпорядника коштів",
    "legalName": "Найменування",
    "edrpou": "ЄДРПОУ",
    "subordination": "Підпорядкованість",
    "additionalInfo": "Додаткова інформація",
  };

  Future<void> exportAccountsToExcel(List<Account> accounts) async {
    final excel = ex.Excel.createExcel();
    final sheet = excel['Accounts'];

    // 1️⃣ Додаємо заголовки (структура з усіма колонками)
    sheet.appendRow([
      ex.TextCellValue("Особовий рахунок"),
      ex.TextCellValue("Номер розпорядника коштів"),
      ex.TextCellValue("Найменування"),
      ex.TextCellValue("ЄДРПОУ"),
      ex.TextCellValue("Підпорядкованість"),
      ex.TextCellValue("Додаткова інформація"),
    ]);

    // 2️⃣ Додаємо дані
    for (final acc in accounts) {
      sheet.appendRow([
        ex.TextCellValue(acc.accountNumber),
        ex.TextCellValue(acc.rozporiadNumber),
        ex.TextCellValue(acc.legalName),
        ex.TextCellValue(acc.edrpou),
        ex.TextCellValue(acc.subordination),
        ex.TextCellValue(
          acc.additionalInfo.isNotEmpty ? acc.additionalInfo : "-",
        ),
      ]);
    }

    // 3️⃣ Збереження
    final fileBytes = excel.save(fileName: "accounts.xlsx")!;

    if (kIsWeb) {
      // Web: завантаження через браузер
      // await FileSaver.instance.saveFile(
      //   name: "accounts.xlsx", // ім'я файлу
      //   bytes: Uint8List.fromList(fileBytes), // байти файлу
      //   mimeType: MimeType.microsoftExcel, // MIME-тип
      // );
      print("✅ Excel збережено:");
    } else {
      // Android/iOS/Desktop: збереження у Documents
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/accounts.xlsx";
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      print("✅ Excel збережено: $filePath");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAccounts() {
    setState(() {
      _futureAccounts = _apiService.fetchAccounts().then((accounts) {
        _filteredAccounts = accounts;
        return accounts;
      });
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _futureAccounts.then((accounts) {
      setState(() {
        if (_searchQuery.isEmpty) {
          _filteredAccounts = accounts;
        } else {
          _filteredAccounts = accounts.where((account) {
            bool matches = false;
            if (_filterOptions['accountNumber'] == true &&
                account.accountNumber.toLowerCase().contains(_searchQuery)) {
              matches = true;
            }
            if (_filterOptions['rozporiadNumber'] == true &&
                account.rozporiadNumber.toLowerCase().contains(_searchQuery)) {
              matches = true;
            }
            if (_filterOptions['legalName'] == true &&
                account.legalName.toLowerCase().contains(_searchQuery)) {
              matches = true;
            }
            if (_filterOptions['edrpou'] == true &&
                account.edrpou.toLowerCase().contains(_searchQuery)) {
              matches = true;
            }
            if (_filterOptions['subordination'] == true &&
                account.subordination.toLowerCase().contains(_searchQuery)) {
              matches = true;
            }
            if (_filterOptions['additionalInfo'] == true &&
                account.additionalInfo.toLowerCase().contains(_searchQuery)) {
              matches = true;
            }
            return matches;
          }).toList();
        }
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged();
  }

  Future<void> _addAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountEditScreen()),
    );
    if (result != null && result is Account) {
      await _apiService.addAccount(result);
      _loadAccounts();
      _showSnackBar('Рахунок успішно додано');
    }
  }

  Future<void> _editAccount(Account account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AccountEditScreen(account: account, isEditing: true),
      ),
    );
    if (result != null && result is Account) {
      await _apiService.updateAccount(result);
      _loadAccounts();
      _showSnackBar('Рахунок успішно оновлено');
    }
  }

  Future<void> _deleteAccount(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити рахунок'),
        content: Text(
          'Ви впевнені, що хочете видалити рахунок ${account.accountNumber}?',
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
      await _apiService.deleteAccount(account.id);
      _loadAccounts();
      _showSnackBar('Рахунок успішно видалено');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Детальна інформація'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Особовий рахунок', account.accountNumber),
              _buildDetailRow(
                'Номер розпорядника коштів',
                account.rozporiadNumber,
              ),
              _buildDetailRow('Найменування', account.legalName),
              _buildDetailRow('ЄДРПОУ', account.edrpou),
              _buildDetailRow('Підпорядкованість', account.subordination),
              if (account.additionalInfo.isNotEmpty)
                _buildDetailRow('Додаткова інформація', account.additionalInfo),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Налаштування фільтрів'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.keys.map((key) {
                    return CheckboxListTile(
                      title: Text(_filterLabels[key] ?? key),
                      value: _filterOptions[key],
                      onChanged: (value) {
                        setDialogState(() {
                          _filterOptions[key] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Скасувати'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: const Text('Застосувати'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Особові рахунки'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () async {
              await exportAccountsToExcel(
                await _futureAccounts,
              ); // твоя функція експорту
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // колір кнопки
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Excel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAccounts),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Пошук рахунків',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Account>>(
              future: _futureAccounts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final accounts = _searchQuery.isEmpty
                      ? snapshot.data!
                      : _filteredAccounts;

                  if (accounts.isEmpty) {
                    return const Center(child: Text("Рахунків не знайдено"));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Кількість колонок
                      const columnCount = 7;
                      final columnWidth = constraints.maxWidth / columnCount;

                      return SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 0,
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
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Text(account.accountNumber),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Text(account.rozporiadNumber),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Text(account.legalName),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Text(account.edrpou),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Text(account.subordination),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Text(
                                      account.additionalInfo.isNotEmpty
                                          ? account.additionalInfo
                                          : "-",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: columnWidth,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () =>
                                              _showAccountDetails(account),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.green,
                                          ),
                                          onPressed: () =>
                                              _editAccount(account),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteAccount(account),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
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
