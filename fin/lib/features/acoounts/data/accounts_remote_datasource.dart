import 'package:fin/core/api/api_service.dart';
import 'package:fin/core/models/account.dart';

class AccountsRemoteDataSource {
  final ApiService api;
  static const prefix = '/api/v1/accounts';
  AccountsRemoteDataSource(this.api);

  Future<List<Account>> fetchAccounts() async {
    final data = await api.get(prefix);
    return (data as List)
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Account> createAccount(Account a) async {
    final res = await api.post(prefix, a.toJson());
    return Account.fromJson(res as Map<String, dynamic>);
  }

  Future<Account> updateAccount(Account a) async {
    final res = await api.put('$prefix/${a.id}', a.toJson());
    return Account.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteAccount(String id) async {
    await api.delete('$prefix/$id');
  }
}
