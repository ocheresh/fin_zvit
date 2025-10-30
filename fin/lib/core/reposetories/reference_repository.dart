import 'package:fin/core/models/reference_item.dart';
import 'package:fin/features/references/data/references_remote_datasource.dart';

class ReferenceRepository {
  final ReferencesRemoteDataSource remote;
  ReferenceRepository({required this.remote});

  Future<Map<String, List<ReferenceItem>>> getAll() => remote.getAll();
  Future<List<ReferenceItem>> getCategory(String name) =>
      remote.getCategory(name);
  Future<List<ReferenceItem>> upsertCategory(String name) =>
      remote.upsertCategory(name);

  Future<ReferenceItem> addItem(
    String cat, {
    required String name,
    String info = '',
  }) => remote.addItem(cat, name: name, info: info);
  Future<ReferenceItem> updateItem(
    String cat,
    String id, {
    String? name,
    String? info,
  }) => remote.updateItem(cat, id, name: name, info: info);
  Future<void> deleteItem(String cat, String id) => remote.deleteItem(cat, id);
  Future<void> deleteCategory(String cat) => remote.deleteCategory(cat);
}
