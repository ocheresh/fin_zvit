import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // ---------------- Рахунки ----------------

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

  // ---------------- Пропозиції ----------------

  Future<List<dynamic>> fetchPropoz() async {
    final res = await http.get(Uri.parse('$baseUrl/propoz'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Помилка при завантаженні пропозицій');
    }
  }

  // Отримати останню пропозицію
  Future<Map<String, dynamic>?> getLastPropoz() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/propoz'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isEmpty) return null;
        // Сортуємо за number, беремо останній
        data.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
        return data.last as Map<String, dynamic>;
      } else if (res.statusCode == 404) {
        // Файл ще не створений, повертаємо null
        return null;
      } else {
        throw Exception('Помилка отримання пропозицій: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка отримання останньої пропозиції: $e');
    }
  }

  Future<int> fetchNextPropozNumber() async {
    final res = await http.get(Uri.parse('$baseUrl/propoz/next'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['next'];
    } else {
      throw Exception('Помилка при отриманні наступного номера');
    }
  }

  Future<Map<String, dynamic>> addPropoz(int? number, String note) async {
    final res = await http.post(
      Uri.parse('$baseUrl/propoz'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'number': number, 'note': note}),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Помилка при створенні пропозиції');
    }
  }

  Future<Map<String, dynamic>> updatePropoz(
    String id,
    int number,
    String note,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/propoz/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'number': number, 'note': note}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Помилка при оновленні пропозиції');
    }
  }

  Future<void> deletePropoz(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/propoz/$id'));
    if (res.statusCode != 200) {
      throw Exception('Помилка при видаленні пропозиції');
    }
  }
}
