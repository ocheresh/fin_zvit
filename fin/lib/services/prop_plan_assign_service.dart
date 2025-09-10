import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prop_plan_assign.dart';

/// Сервіс для роботи з пропозиціями до плану асигнувань.
/// Використовує параметри: рік, КПКВ та фонд — для збереження і завантаження окремих файлів.
class PropPlanAssignService {
  final String baseUrl;

  PropPlanAssignService(this.baseUrl);

  /// Формує endpoint для конкретного набору параметрів
  String _endpoint(int year, String kpkv, String fund) {
    return '$baseUrl/prop-plan-assign/$year/$kpkv/$fund';
  }

  /// Завантаження планів
  Future<List<PropPlanAssign>> fetchPlans(
    int year,
    String kpkv,
    String fund,
  ) async {
    final response = await http.get(Uri.parse(_endpoint(year, kpkv, fund)));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => PropPlanAssign.fromJson(e)).toList();
    } else {
      throw Exception('Не вдалося завантажити плани');
    }
  }

  /// Додавання нового плану
  Future<PropPlanAssign> addPlan({
    required int year,
    required String kpkv,
    required String fund,
    required PropPlanAssign plan,
  }) async {
    final response = await http.post(
      Uri.parse(_endpoint(year, kpkv, fund)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plan.toJson()),
    );
    if (response.statusCode == 201) {
      return PropPlanAssign.fromJson(json.decode(response.body));
    } else {
      throw Exception('Не вдалося додати план');
    }
  }

  /// Оновлення плану
  Future<PropPlanAssign> updatePlan(
    int year,
    String kpkv,
    String fund,
    PropPlanAssign plan,
  ) async {
    final response = await http.put(
      Uri.parse('${_endpoint(year, kpkv, fund)}/${plan.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plan.toJson()),
    );
    if (response.statusCode == 200) {
      return PropPlanAssign.fromJson(json.decode(response.body));
    } else {
      throw Exception('Не вдалося оновити план');
    }
  }

  /// Видалення плану
  Future<void> deletePlan(int year, String kpkv, String fund, String id) async {
    final response = await http.delete(
      Uri.parse('${_endpoint(year, kpkv, fund)}/$id'),
    );
    if (response.statusCode != 204) {
      throw Exception('Не вдалося видалити план');
    }
  }
}
