class PropPlanAssign {
  final String? id; // nullable для нових записів
  final String accountId;
  final String legalName;
  final String kekvId;
  final List<int> months;
  final String? additionalInfo;
  bool isSelected; // нове поле для чекбокса

  PropPlanAssign({
    this.id,
    required this.accountId,
    required this.legalName,
    required this.kekvId,
    required this.months,
    this.additionalInfo,
    this.isSelected = false, // за замовчуванням false
  }) : assert(months.length == 12, "Months list must have 12 values");

  // 🔹 Обчислення суми всіх місяців
  int get total => months.fold(0, (a, b) => a + b);

  // 🔹 Обчислення "плану поточного місяця"
  int get currentMonth =>
      months.take(DateTime.now().month).fold(0, (a, b) => a + b);

  factory PropPlanAssign.fromJson(Map<String, dynamic> json) {
    final months = List<int>.from(json['months']);
    return PropPlanAssign(
      id: json['id'] as String?,
      accountId: json['accountId'] as String,
      legalName: json['legalName'] as String,
      kekvId: json['kekvId'] as String,
      months: months,
      additionalInfo: json['additionalInfo'] as String?,
      isSelected: json['isSelected'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'accountId': accountId,
      'legalName': legalName,
      'kekvId': kekvId,
      'months': months,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
      'isSelected': isSelected,
      // 🔹 total і currentMonth не зберігаємо, бо вони обчислювані
    };
  }
}
