import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/reference_item.dart';

class ReferenceApiService {
  final String baseUrl;

  ReferenceApiService(this.baseUrl);

  /// Отримати всі категорії з підрозділами
  Future<Map<String, List<ReferenceItem>>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/references'));
    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження категорій');
    }
    final Map<String, dynamic> data = json.decode(response.body);

    // Перетворюємо JSON у ReferenceItem
    final Map<String, List<ReferenceItem>> result = {};
    data.forEach((key, value) {
      result[key] = (value as List)
          .map((item) => ReferenceItem.fromJson(item))
          .toList();
    });
    return result;
  }

  /// Додати новий елемент до категорії
  Future<void> addItem(String category, String name, {String info = ''}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/references/$category/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'info': info}),
    );
    if (response.statusCode != 201) {
      throw Exception('Помилка додавання елемента');
    }
  }

  /// Оновити існуючий елемент
  Future<void> updateItem(
    String category,
    String id,
    String name, {
    String info = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/references/$category/items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'info': info}),
    );
    if (response.statusCode != 200) {
      throw Exception('Помилка оновлення елемента');
    }
  }

  /// Видалити елемент
  Future<void> deleteItem(String category, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/references/$category/items/$id'),
    );
    if (response.statusCode != 204) {
      throw Exception('Помилка видалення елемента');
    }
  }

  /// Видалити категорію
  Future<void> deleteCategory(String category) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/references/$category'),
    );
    if (response.statusCode != 204) {
      throw Exception('Помилка видалення категорії');
    }
  }

  /// Додати нову категорію
  Future<void> addCategory(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/references'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );

    if (response.statusCode != 201) {
      // Спробуємо отримати повідомлення з тіла відповіді
      String message = 'Помилка додавання категорії';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) message = data['error'];
      } catch (_) {
        // Ігноруємо помилки парсингу
      }
      throw Exception(message);
    }
  }
}
