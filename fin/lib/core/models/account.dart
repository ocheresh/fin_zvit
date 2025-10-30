class Account {
  final String? id;
  final String accountNumber;
  final String rozporiadNumber;
  final String legalName;
  final String edrpou;
  final String? subordination;
  final String additionalInfo;

  Account({
    this.id,
    required this.accountNumber,
    required this.rozporiadNumber,
    required this.legalName,
    required this.edrpou,
    this.subordination,
    this.additionalInfo = '',
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
    id: j['id'] as String?,
    accountNumber: j['accountNumber'] ?? '',
    rozporiadNumber: j['rozporiadNumber'] ?? '',
    legalName: j['legalName'] ?? '',
    edrpou: j['edrpou'] ?? '',
    subordination: j['subordination'],
    additionalInfo: j['additionalInfo'] ?? '',
  );

  Map<String, dynamic> toJson() {
    final m = {
      'accountNumber': accountNumber,
      'rozporiadNumber': rozporiadNumber,
      'legalName': legalName,
      'edrpou': edrpou,
      'subordination': subordination,
      'additionalInfo': additionalInfo,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
