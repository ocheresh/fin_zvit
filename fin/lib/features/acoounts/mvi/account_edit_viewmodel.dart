import 'package:flutter/foundation.dart';
import '/../core/models/account.dart';
import '/../core/api/api_service.dart';

class AccountEditViewModel extends ChangeNotifier {
  final ApiService api;
  AccountEditViewModel({required this.api});

  bool loading = false;
  List<Map<String, dynamic>> subordinationList = [];
  int? selectedSubId;

  Account? account;

  void init(Account? accountToEdit) {
    account = accountToEdit;
  }

  Account buildAccount({
    required String rozporiadNumber,
    required String accountNumber,
    required String legalName,
    required String edrpou,
    required String subordination,
    required String additionalInfo,
  }) {
    return Account(
      id: account?.id,
      rozporiadNumber: rozporiadNumber,
      accountNumber: accountNumber,
      legalName: legalName,
      edrpou: edrpou,
      subordination: subordination,
      additionalInfo: additionalInfo,
    );
  }
}
