import 'package:flutter/foundation.dart';
import 'reference_intent.dart';
import 'reference_state.dart';
import 'package:fin/core/reposetories/reference_repository.dart';
// import 'package:fin/core/models/reference_item.dart';

class ReferenceViewModel extends ChangeNotifier {
  final ReferenceRepository repo;
  ReferenceState state = ReferenceState.initial();

  ReferenceViewModel({required this.repo});

  Future<void> dispatch(ReferenceIntent intent) async {
    try {
      state = state.copy(loading: true, error: null);
      notifyListeners();

      switch (intent) {
        case LoadAll():
          final data = await repo.getAll();
          state = state.copy(loading: false, data: data);
          break;

        case CreateCategory(name: final n):
          await repo.upsertCategory(n);
          final data = await repo.getAll();
          state = state.copy(loading: false, data: data);
          break;

        case DeleteCategory(name: final n):
          await repo.deleteCategory(n);
          final data2 = await repo.getAll();
          state = state.copy(loading: false, data: data2);
          break;

        case AddItem(category: final c, name: final nm, info: final inf):
          await repo.addItem(c, name: nm, info: inf);
          final d1 = await repo.getAll();
          state = state.copy(loading: false, data: d1);
          break;

        case EditItem(
          category: final c,
          id: final id,
          name: final nm,
          info: final inf,
        ):
          await repo.updateItem(c, id, name: nm, info: inf);
          final d2 = await repo.getAll();
          state = state.copy(loading: false, data: d2);
          break;

        case DeleteItem(category: final c, id: final id):
          await repo.deleteItem(c, id);
          final d3 = await repo.getAll();
          state = state.copy(loading: false, data: d3);
          break;
      }
    } catch (e) {
      state = state.copy(loading: false, error: e.toString());
    } finally {
      notifyListeners();
    }
  }
}
