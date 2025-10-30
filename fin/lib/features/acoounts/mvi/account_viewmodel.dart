import 'package:flutter/foundation.dart';
import '../../../core/models/account.dart';

import 'package:fin/core/reposetories/account_repository.dart';
import 'account_state.dart';
import 'account_intent.dart';

class AccountViewModel extends ChangeNotifier {
  AccountsState _state = const AccountsState();
  final AccountRepository repo;
  AccountsState get state => _state;

  AccountViewModel({required this.repo});

  Future<void> onIntent(AccountIntent intent) async {
    if (intent is LoadAccountsIntent) return _load();
    if (intent is AddAccountIntent) return _add(intent.account);
    if (intent is EditAccountIntent) return _edit(intent.account);
    if (intent is DeleteAccountIntent) return _delete(intent.id);
  }

  Future<void> _load() async {
    _set(_state.copyWith(status: LoadStatus.loading));
    try {
      final list = await repo.getAll();
      _set(_state.copyWith(accounts: list, status: LoadStatus.idle));
    } catch (e) {
      _set(_state.copyWith(status: LoadStatus.error, error: e.toString()));
    }
  }

  Future<void> _add(Account a) async {
    try {
      final created = await repo.create(a);
      _set(_state.copyWith(accounts: [created, ..._state.accounts]));
    } catch (e) {
      _set(_state.copyWith(status: LoadStatus.error, error: e.toString()));
    }
  }

  Future<void> _edit(Account a) async {
    try {
      final updated = await repo.update(a);
      final newList = _state.accounts
          .map((x) => x.id == updated.id ? updated : x)
          .toList();
      _set(_state.copyWith(accounts: newList));
    } catch (e) {
      _set(_state.copyWith(status: LoadStatus.error, error: e.toString()));
    }
  }

  Future<void> _delete(String id) async {
    try {
      await repo.delete(id);
      _set(
        _state.copyWith(
          accounts: _state.accounts.where((a) => a.id != id).toList(),
        ),
      );
    } catch (e) {
      _set(_state.copyWith(status: LoadStatus.error, error: e.toString()));
    }
  }

  void _set(AccountsState s) {
    _state = s;
    notifyListeners();
  }
}
