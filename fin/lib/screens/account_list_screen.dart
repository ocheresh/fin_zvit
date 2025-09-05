import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'account_edit_screen.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreenState createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late Future<List<Account>> futureAccounts;
  final ApiService _apiService = ApiService();
  List<Account> _filteredAccounts = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Фільтри
  final Map<String, bool> _filterOptions = {
    'accountNumber': true,
    'rozporiadNumber': true,
    'legalName': true,
    'edrpou': true,
    'subordination': true,
    'additionalInfo': true, // Додано фільтр для додаткової інформації
  };

  @override
  void initState() {
    super.initState();
    _refreshAccounts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _refreshAccounts() {
    setState(() {
      futureAccounts = _apiService.fetchAccounts().then((accounts) {
        _filteredAccounts = accounts;
        return accounts;
      });
    });
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      futureAccounts.then((accounts) {
        setState(() {
          _filteredAccounts = accounts;
        });
      });
      return;
    }

    futureAccounts.then((accounts) {
      setState(() {
        _filteredAccounts = accounts.where((account) {
          bool matches = false;

          if (_filterOptions['accountNumber'] == true) {
            matches =
                matches ||
                account.accountNumber.toLowerCase().contains(_searchQuery);
          }
          if (_filterOptions['rozporiadNumber'] == true) {
            matches =
                matches ||
                account.rozporiadNumber.toLowerCase().contains(_searchQuery);
          }
          if (_filterOptions['legalName'] == true) {
            matches =
                matches ||
                account.legalName.toLowerCase().contains(_searchQuery);
          }
          if (_filterOptions['edrpou'] == true) {
            matches =
                matches || account.edrpou.toLowerCase().contains(_searchQuery);
          }
          if (_filterOptions['subordination'] == true) {
            matches =
                matches ||
                account.subordination.toLowerCase().contains(_searchQuery);
          }
          if (_filterOptions['additionalInfo'] == true) {
            matches =
                matches ||
                account.additionalInfo.toLowerCase().contains(_searchQuery);
          }

          return matches;
        }).toList();
      });
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Налаштування фільтрів'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: Text('Особовий рахунок'),
                      value: _filterOptions['accountNumber'],
                      onChanged: (value) {
                        setState(() {
                          _filterOptions['accountNumber'] = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Розпорядний номер'),
                      value: _filterOptions['rozporiadNumber'],
                      onChanged: (value) {
                        setState(() {
                          _filterOptions['rozporiadNumber'] = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Найменування'),
                      value: _filterOptions['legalName'],
                      onChanged: (value) {
                        setState(() {
                          _filterOptions['legalName'] = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('ЄДРПОУ'),
                      value: _filterOptions['edrpou'],
                      onChanged: (value) {
                        setState(() {
                          _filterOptions['edrpou'] = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Підпорорядкованість'),
                      value: _filterOptions['subordination'],
                      onChanged: (value) {
                        setState(() {
                          _filterOptions['subordination'] = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Додаткова інформація'),
                      value: _filterOptions['additionalInfo'],
                      onChanged: (value) {
                        setState(() {
                          _filterOptions['additionalInfo'] = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Скасувати'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: Text('Застосувати'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _addAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountEditScreen()),
    );

    if (result != null && result is Account) {
      await _apiService.addAccount(result);
      _refreshAccounts();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Рахунок успішно додано')));
    }
  }

  void _editAccount(Account account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AccountEditScreen(account: account, isEditing: true),
      ),
    );

    if (result != null && result is Account) {
      await _apiService.updateAccount(result);
      _refreshAccounts();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Рахунок успішно оновлено')));
    }
  }

  void _deleteAccount(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Видалити рахунок'),
        content: Text(
          'Ви впевнені, що хочете видалити рахунок ${account.accountNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Видалити', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _apiService.deleteAccount(account.id);
      _refreshAccounts();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Рахунок успішно видалено')));
    }
  }

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Детальна інформація'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Особовий рахунок:', account.accountNumber),
              _buildDetailRow('Розпорядний номер:', account.rozporiadNumber),
              _buildDetailRow('Найменування:', account.legalName),
              _buildDetailRow('ЄДРПОУ:', account.edrpou),
              _buildDetailRow('Підпорядкованість:', account.subordination),
              if (account.additionalInfo.isNotEmpty)
                _buildDetailRow(
                  'Додаткова інформація:',
                  account.additionalInfo,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрити'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Особові рахунки'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Фільтри пошуку',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshAccounts,
            tooltip: 'Оновити',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Пошук рахунків',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Введіть текст для пошуку...',
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Знайдено: ${_filteredAccounts.length} рахунків',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _clearSearch,
                    child: Text('Очистити пошук'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Account>>(
              future: futureAccounts,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final accounts = _searchQuery.isEmpty
                      ? snapshot.data!
                      : _filteredAccounts;

                  if (accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Немає рахунків'
                                : 'Рахунків не знайдено',
                            style: TextStyle(fontSize: 18),
                          ),
                          if (_searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: _clearSearch,
                              child: Text('Очистити пошук'),
                            ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Особовий рахунок')),
                        DataColumn(label: Text('Розпорядний номер')),
                        DataColumn(label: Text('Найменування')),
                        DataColumn(label: Text('ЄДРПОУ')),
                        DataColumn(label: Text('Підпорядкованість')),
                        DataColumn(label: Text('Додаткова інформація')),
                        DataColumn(label: Text('Дії')),
                      ],
                      rows: accounts.map((account) {
                        return DataRow(
                          onLongPress: () => _showAccountDetails(account),
                          cells: [
                            DataCell(
                              Text(account.accountNumber),
                              onTap: () => _showAccountDetails(account),
                            ),
                            DataCell(
                              Text(account.rozporiadNumber),
                              onTap: () => _showAccountDetails(account),
                            ),
                            DataCell(
                              Text(account.legalName),
                              onTap: () => _showAccountDetails(account),
                            ),
                            DataCell(
                              Text(account.edrpou),
                              onTap: () => _showAccountDetails(account),
                            ),
                            DataCell(
                              Text(account.subordination),
                              onTap: () => _showAccountDetails(account),
                            ),
                            DataCell(
                              Container(
                                width: 150, // Фіксована ширина
                                child: Text(
                                  account.additionalInfo.isNotEmpty
                                      ? account.additionalInfo
                                      : '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              onTap: () => _showAccountDetails(account),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.visibility,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        _showAccountDetails(account),
                                    tooltip: 'Переглянути деталі',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                    onPressed: () => _editAccount(account),
                                    tooltip: 'Редагувати',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteAccount(account),
                                    tooltip: 'Видалити',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Помилка: ${snapshot.error}'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
        tooltip: 'Додати рахунок',
      ),
    );
  }
}
