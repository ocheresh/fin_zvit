import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';

class ApiService {
  final String baseUrl; // приклад: "http://192.168.1.50:3000"

  ApiService(this.baseUrl);

  // Отримати всі рахунки
  Future<List<Account>> fetchAccounts() async {
    final res = await http.get(Uri.parse('$baseUrl/accounts'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => Account.fromJson(e)).toList();
    } else {
      throw Exception('Помилка при завантаженні рахунків');
    }
  }

  // Додати рахунок
  Future<Account> addAccount(Account account) async {
    final res = await http.post(
      Uri.parse('$baseUrl/accounts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(account.toJson()),
    );
    if (res.statusCode == 201) {
      return Account.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Помилка при створенні рахунку');
    }
  }

  // Оновити рахунок
  Future<Account> updateAccount(Account account) async {
    final res = await http.put(
      Uri.parse('$baseUrl/accounts/${account.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(account.toJson()),
    );
    if (res.statusCode == 200) {
      return Account.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Помилка при оновленні рахунку');
    }
  }

  // Видалити рахунок
  Future<void> deleteAccount(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/accounts/$id'));
    if (res.statusCode != 204) {
      throw Exception('Помилка при видаленні рахунку');
    }
  }
}
