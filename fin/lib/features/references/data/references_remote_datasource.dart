// import 'dart:convert';
import 'package:fin/core/api/api_service.dart';
import 'package:fin/core/models/reference_item.dart';

class ReferencesRemoteDataSource {
  final ApiService api;
  static const prefix = '/api/v1/references';
  ReferencesRemoteDataSource(this.api);

  Future<Map<String, List<ReferenceItem>>> getAll() async {
    final data = await api.get(prefix); // {cat: [..]}
    final map = <String, List<ReferenceItem>>{};
    (data as Map<String, dynamic>).forEach((k, v) {
      map[k] = (v as List).map((e) => ReferenceItem.fromJson(e)).toList();
    });
    return map;
  }

  Future<List<ReferenceItem>> getCategory(String category) async {
    final list = await api.get('$prefix/$category') as List<dynamic>;
    return list.map((e) => ReferenceItem.fromJson(e)).toList();
  }

  Future<List<ReferenceItem>> upsertCategory(String category) async {
    final res = await api.post('$prefix/$category', {'category': category});
    return (res as List).map((e) => ReferenceItem.fromJson(e)).toList();
  }

  Future<ReferenceItem> addItem(
    String category, {
    required String name,
    String info = '',
  }) async {
    final res = await api.post('/api/references/$category/items', {
      'name': name,
      'info': info,
    });
    return ReferenceItem.fromJson(res);
  }

  Future<ReferenceItem> updateItem(
    String category,
    String id, {
    String? name,
    String? info,
  }) async {
    final res = await api.put('$prefix/$category/items/$id', {
      if (name != null) 'name': name,
      if (info != null) 'info': info,
    });
    return ReferenceItem.fromJson(res);
  }

  Future<void> deleteItem(String category, String id) async {
    await api.delete('$prefix/$category/items/$id');
  }

  Future<void> deleteCategory(String category) async {
    await api.delete('$prefix/category/$category');
  }
}
