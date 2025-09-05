class Account {
  String id;
  String rozporiadNumber;
  String accountNumber;
  String legalName;
  String edrpou;
  String subordination;
  String additionalInfo; // Додано нове поле

  Account({
    required this.id,
    required this.rozporiadNumber,
    required this.accountNumber,
    required this.legalName,
    required this.edrpou,
    required this.subordination,
    this.additionalInfo = '', // Додано з значенням за замовчуванням
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      rozporiadNumber: json['rozporiadNumber'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      legalName: json['legalName'] ?? '',
      edrpou: json['edrpou'] ?? '',
      subordination: json['subordination'] ?? '',
      additionalInfo: json['additionalInfo'] ?? '', // Додано
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rozporiadNumber': rozporiadNumber,
      'accountNumber': accountNumber,
      'legalName': legalName,
      'edrpou': edrpou,
      'subordination': subordination,
      'additionalInfo': additionalInfo, // Додано
    };
  }

  Account copyWith({
    String? id,
    String? rozporiadNumber,
    String? accountNumber,
    String? legalName,
    String? edrpou,
    String? subordination,
    String? additionalInfo, // Додано
  }) {
    return Account(
      id: id ?? this.id,
      rozporiadNumber: rozporiadNumber ?? this.rozporiadNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      legalName: legalName ?? this.legalName,
      edrpou: edrpou ?? this.edrpou,
      subordination: subordination ?? this.subordination,
      additionalInfo: additionalInfo ?? this.additionalInfo, // Додано
    );
  }
}