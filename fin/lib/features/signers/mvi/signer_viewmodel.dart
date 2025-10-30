import 'package:flutter/material.dart';
import 'package:fin/core/models/signer.dart';
import '../../../core/reposetories/signers_repository.dart';
import 'signer_intent.dart';
import 'signer_state.dart';

class SignerViewModel extends ChangeNotifier {
  final SignersRepository repo;
  SignerState _state = const SignerState(loading: false, items: []);
  SignerState get state => _state;

  SignerViewModel({required this.repo});

  Future<void> dispatch(SignerIntent intent) async {
    try {
      if (intent is LoadAll) {
        _set(_state.copy(loading: true, error: null));
        final data = await repo.load();
        _set(_state.copy(loading: false, items: data));
      } else if (intent is CreateSigner) {
        _set(_state.copy(loading: true, error: null));
        final created = await repo.create(intent.signer);
        _set(_state.copy(loading: false, items: [..._state.items, created]));
      } else if (intent is UpdateSigner) {
        _set(_state.copy(loading: true, error: null));
        final upd = await repo.update(intent.signer);
        final items = _state.items
            .map((e) => e.id == upd.id ? upd : e)
            .toList();
        _set(_state.copy(loading: false, items: items));
      } else if (intent is DeleteSigner) {
        _set(_state.copy(loading: true, error: null));
        await repo.delete(intent.id);
        final items = _state.items.where((e) => e.id != intent.id).toList();
        _set(_state.copy(loading: false, items: items));
      }
    } catch (e) {
      _set(_state.copy(loading: false, error: e.toString()));
    }
  }

  void _set(SignerState s) {
    _state = s;
    notifyListeners();
  }
}
