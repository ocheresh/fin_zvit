class Account {
  int id;
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
    this.subordination = '', // <-- новий аргумент із дефолтом
    this.additionalInfo = '', // Додано з значенням за замовчуванням
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int parsedId = switch (rawId) {
      int v => v,
      String s => int.tryParse(s) ?? DateTime.now().millisecondsSinceEpoch,
      _ => DateTime.now().millisecondsSinceEpoch,
    };

    return Account(
      id: parsedId,
      rozporiadNumber: json['rozporiadNumber'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      legalName: json['legalName'] ?? '',
      edrpou: json['edrpou'] ?? '',
      subordination:
          json['subordination'] ??
          '', // <-- читаємо, якщо бекенд підкладає name
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
      'subordination': subordination, // <-- кладемо назад (якщо треба)
      'additionalInfo': additionalInfo, // Додано
    };
  }

  Account copyWith({
    int? id,
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
      subordination: subordination ?? this.subordination, // <-- додали
      additionalInfo: additionalInfo ?? this.additionalInfo, // Додано
    );
  }
}
