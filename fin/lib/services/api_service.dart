import '../models/account.dart';

class ApiService {
  // Тимчасово використовуємо мок дані
  List<Account> _accounts = [];
  bool _useMockData = true; // Прапорець для перемикання між мок і реальними даними

  ApiService() {
    _initMockData();
  }

  void _initMockData() {
    _accounts = [
      Account(
        id: '1',
        accountNumber: '001122',
        rozporiadNumber: '3444',
        legalName: 'ТОВ "Приклад 1"',
        edrpou: '12345678',
        subordination: 'Міністерство А',
      ),
      Account(
        id: '2',
        accountNumber: '001123',
        rozporiadNumber: '3444',
        legalName: 'ТОВ "Приклад 2"',
        edrpou: '87654321',
        subordination: 'Міністерство Б',
      ),
      Account(
        id: '3',
        accountNumber: '001124',
        rozporiadNumber: '3444',
        legalName: 'ТОВ "Приклад 3"',
        edrpou: '11111111',
        subordination: 'Міністерство В',
      ),
    ];
  }

  Future<List<Account>> fetchAccounts() async {
    if (_useMockData) {
      return _fetchAccountsMock();
    } else {
      return _fetchAccountsReal();
    }
  }

  Future<List<Account>> _fetchAccountsMock() async {
    await Future.delayed(Duration(seconds: 1));
    return List.from(_accounts);
  }

  Future<Account> addAccount(Account account) async {
    if (_useMockData) {
      return _addAccountMock(account);
    } else {
      return _addAccountReal(account);
    }
  }

  Future<Account> _addAccountMock(Account account) async {
    await Future.delayed(Duration(milliseconds: 500));
    final newAccount = account.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _accounts.add(newAccount);
    return newAccount;
  }

  Future<Account> updateAccount(Account account) async {
    if (_useMockData) {
      return _updateAccountMock(account);
    } else {
      return _updateAccountReal(account);
    }
  }

  Future<Account> _updateAccountMock(Account account) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      return account;
    }
    throw Exception('Рахунок не знайдено');
  }

  Future<void> deleteAccount(String id) async {
    if (_useMockData) {
      return _deleteAccountMock(id);
    } else {
      return _deleteAccountReal(id);
    }
  }

  Future<void> _deleteAccountMock(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    _accounts.removeWhere((account) => account.id == id);
  }

  // Методи для реального бекенду (поки заглушки)
  Future<List<Account>> _fetchAccountsReal() async {
    // Тут буде реальна реалізація, коли налаштуємо бекенд
    await Future.delayed(Duration(seconds: 2));
    throw Exception('Реальний бекенд ще не налаштовано. Використовуються мок дані.');
  }

  Future<Account> _addAccountReal(Account account) async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('Реальний бекенд ще не налаштовано. Використовуються мок дані.');
  }

  Future<Account> _updateAccountReal(Account account) async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('Реальний бекенд ще не налаштовано. Використовуються мок дані.');
  }

  Future<void> _deleteAccountReal(String id) async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('Реальний бекенд ще не налаштовано. Використовуються мок дані.');
  }

  // Метод для перемикання між мок і реальними даними
  void toggleUseMockData(bool useMock) {
    _useMockData = useMock;
  }

  // Геттер для перевірки поточного режиму
  bool get isUsingMockData => _useMockData;
}