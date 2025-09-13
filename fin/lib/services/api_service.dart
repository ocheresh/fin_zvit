import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import 'package:fin/models/res_propoz.dart';

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
        data.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
        return data.last as Map<String, dynamic>;
      } else if (res.statusCode == 404) {
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

  Future<Map<String, dynamic>> addPropoz(
    int? number,
    String note,
    String kpkv,
    String fond,
  ) async {
    final date = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final res = await http.post(
      Uri.parse('$baseUrl/propoz'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'number': number,
        'note': note,
        'date': date,
        'kpkv': kpkv,
        'fond': fond,
      }),
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
    String kpkv,
    String fond,
  ) async {
    final date = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final res = await http.put(
      Uri.parse('$baseUrl/propoz/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'number': number,
        'note': note,
        'date': date,
        'kpkv': kpkv,
        'fond': fond,
      }),
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
  // ---------------- ДОДАТКОВИЙ МЕТОД ДЛЯ НОВОЇ БАЗИ ----------------

  // ---------------- GET ALL ResPropoz ----------------
  Future<List<ResPropoz>> fetchResPropoz(
    int year,
    String kpkv,
    String fond,
  ) async {
    final url = '$baseUrl/res_plan_assign/$year/$kpkv/$fond';
    final res = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(res.body);
      return decoded.map((e) => ResPropoz.fromJson(e)).toList();
    } else {
      throw Exception(
        'Помилка при завантаженні ResPropoz: ${res.statusCode} → ${res.body}',
      );
    }
  }

  // ---------------- CREATE ResPropoz ----------------
  Future<ResPropoz> addResPropoz(
    List<Map<String, dynamic>> items,
    int year,
    String kpkv,
    String fond,
    String numberPropose,
  ) async {
    final url = '$baseUrl/res_plan_assign/$year/$kpkv/$fond';
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numberPropose': numberPropose,
        'items': items,
        'year': year,
        'kpkv': kpkv,
        'fond': fond,
      }),
    );

    if (res.statusCode == 201) {
      final decoded = jsonDecode(res.body);
      return ResPropoz.fromJson(decoded);
    } else {
      throw Exception(
        'Помилка при створенні ResPropoz: ${res.statusCode} → ${res.body}',
      );
    }
  }

  // ---------------- UPDATE ResPropoz ----------------
  Future<ResPropoz> updateResPropoz(
    int year,
    String kpkv,
    String fond,
    int id,
    ResPropoz updated,
  ) async {
    final url = '$baseUrl/res_plan_assign/$year/$kpkv/$fond/$id';
    final res = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated.toJson()),
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return ResPropoz.fromJson(decoded);
    } else {
      throw Exception(
        'Помилка при оновленні ResPropoz: ${res.statusCode} → ${res.body}',
      );
    }
  }

  // ---------------- DELETE ResPropoz ----------------
  Future<void> deleteResPropoz(
    int year,
    String kpkv,
    String fond,
    int id,
  ) async {
    final url = '$baseUrl/res_plan_assign/$year/$kpkv/$fond/$id';
    final res = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 204) {
      throw Exception(
        'Помилка при видаленні ResPropoz: ${res.statusCode} → ${res.body}',
      );
    }
  }
}
