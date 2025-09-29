class Account {
  /// ID з БД (INT AUTO_INCREMENT). Для нових записів може бути null.
  final int? id;

  final String rozporiadNumber;
  final String accountNumber;
  final String legalName;
  final String edrpou;

  /// FK на Subordination(id) для API
  final int? subordinationId;

  /// Людська назва підпорядкування (для UI, опційно)
  final String? subordination;

  /// Необовʼязкові примітки
  final String additionalInfo;

  const Account({
    this.id,
    required this.rozporiadNumber,
    required this.accountNumber,
    required this.legalName,
    required this.edrpou,
    this.subordinationId,
    this.subordination,
    this.additionalInfo = '',
  });

  /// Універсальний парсер (підтримує як рядкові, так і числові id)
  factory Account.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    String _s(dynamic v) => (v ?? '').toString().trim();

    return Account(
      id: _toInt(json['id']),
      rozporiadNumber: _s(json['rozporiadNumber']),
      accountNumber: _s(json['accountNumber']),
      legalName: _s(json['legalName']),
      edrpou: _s(json['edrpou']),
      subordinationId: _toInt(json['subordinationId']),
      subordination: json['subordination'] != null
          ? _s(json['subordination'])
          : null,
      additionalInfo: _s(json['additionalInfo']),
    );
  }

  /// Мінімальний JSON для локального зберігання/UI (включає назву підпорядкування)
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'rozporiadNumber': rozporiadNumber,
    'accountNumber': accountNumber,
    'legalName': legalName,
    'edrpou': edrpou,
    'subordinationId': subordinationId,
    'subordination': subordination,
    'additionalInfo': additionalInfo,
  };

  /// JSON саме для API (бек очікує subordinationId, а не назву)
  Map<String, dynamic> toApiJson() => {
    if (id != null) 'id': id,
    'rozporiadNumber': rozporiadNumber,
    'accountNumber': accountNumber,
    'legalName': legalName,
    'edrpou': edrpou,
    'subordinationId': subordinationId,
    'subordination': subordination,
    'additionalInfo': additionalInfo,
  };

  Account copyWith({
    int? id,
    String? rozporiadNumber,
    String? accountNumber,
    String? legalName,
    String? edrpou,
    int? subordinationId,
    String? subordination,
    String? additionalInfo,
  }) {
    return Account(
      id: id ?? this.id,
      rozporiadNumber: rozporiadNumber ?? this.rozporiadNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      legalName: legalName ?? this.legalName,
      edrpou: edrpou ?? this.edrpou,
      subordinationId: subordinationId ?? this.subordinationId,
      subordination: subordination ?? this.subordination,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() =>
      'Account(id: $id, acc: $accountNumber, name: $legalName, edrpou: $edrpou, subId: $subordinationId, sub: $subordination)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rozporiadNumber == other.rozporiadNumber &&
          accountNumber == other.accountNumber &&
          legalName == other.legalName &&
          edrpou == other.edrpou &&
          subordinationId == other.subordinationId &&
          subordination == other.subordination &&
          additionalInfo == other.additionalInfo;

  @override
  int get hashCode => Object.hash(
    id,
    rozporiadNumber,
    accountNumber,
    legalName,
    edrpou,
    subordinationId,
    subordination,
    additionalInfo,
  );
}
