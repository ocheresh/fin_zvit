import '../models/account.dart';
import 'package:fin/features/acoounts/data/accounts_remote_datasource.dart';

class AccountRepository {
  final AccountsRemoteDataSource remote;
  AccountRepository(this.remote);

  Future<List<Account>> getAll() => remote.fetchAccounts();
  Future<Account> create(Account a) => remote.createAccount(a);
  Future<Account> update(Account a) => remote.updateAccount(a);
  Future<void> delete(String id) => remote.deleteAccount(id);
}
