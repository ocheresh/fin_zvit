import 'package:flutter/foundation.dart';

import '../data/reestrprop_remote_datasource.dart';
import 'reestrprop_intent.dart';
import 'reestrprop_state.dart';

class ReestrPropViewModel extends ChangeNotifier {
  final ReestrPropRemoteDataSource repo;
  ReestrPropState state = const ReestrPropState();

  ReestrPropViewModel({required this.repo});

  Future<void> dispatch(ReestrPropIntent i) async {
    try {
      switch (i) {
        case RPLoad():
          state = state.copy(loading: true, error: null);
          notifyListeners();
          final list = await repo.fetchAll();
          list.sort((a, b) => a.seqNo.compareTo(b.seqNo));
          state = state.copy(loading: false, items: list);
          notifyListeners();
          break;

        case RPCreate(
          :final kpkvId,
          :final fundId,
          :final month,
          :final signFirstId,
          :final signSecondId,
          :final sentDf,
          :final acceptedDf,
        ):
          state = state.copy(loading: true, error: null);
          notifyListeners();
          final created = await repo.createItem(
            kpkvId: kpkvId,
            fundId: fundId,
            month: month,
            signFirstId: signFirstId,
            signSecondId: signSecondId,
            sentDf: sentDf,
            acceptedDf: acceptedDf,
          );
          final items = [...state.items, created]
            ..sort((a, b) => a.seqNo.compareTo(b.seqNo));
          state = state.copy(loading: false, items: items);
          notifyListeners();
          break;

        case RPUpdate(:final id, :final patch):
          state = state.copy(loading: true, error: null);
          notifyListeners();
          final updated = await repo.updateItem(id, patch);
          final items = state.items
              .map((e) => e.id == id ? updated : e)
              .toList();
          state = state.copy(loading: false, items: items);
          notifyListeners();
          break;

        case RPDelete(:final id):
          state = state.copy(loading: true, error: null);
          notifyListeners();
          await repo.deleteItem(id);
          final items = state.items.where((e) => e.id != id).toList();
          state = state.copy(loading: false, items: items);
          notifyListeners();
          break;
      }
    } catch (e) {
      state = state.copy(loading: false, error: e.toString());
      notifyListeners();
    }
  }
}
