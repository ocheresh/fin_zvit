import '../../../core/models/account.dart';

abstract class AccountIntent {}

class LoadAccountsIntent extends AccountIntent {}

class AddAccountIntent extends AccountIntent {
  final Account account;
  AddAccountIntent(this.account);
}

class EditAccountIntent extends AccountIntent {
  final Account account;
  EditAccountIntent(this.account);
}

class DeleteAccountIntent extends AccountIntent {
  final String id;
  DeleteAccountIntent(this.id);
}
