import '../../../core/models/account.dart';

enum LoadStatus { idle, loading, error }

class AccountsState {
  final List<Account> accounts;
  final LoadStatus status;
  final String? error;

  const AccountsState({
    this.accounts = const [],
    this.status = LoadStatus.idle,
    this.error,
  });

  AccountsState copyWith({
    List<Account>? accounts,
    LoadStatus? status,
    String? error,
  }) => AccountsState(
    accounts: accounts ?? this.accounts,
    status: status ?? this.status,
    error: error ?? this.error,
  );
}
