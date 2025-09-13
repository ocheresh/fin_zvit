class ResPropoz {
  final int id;
  final int year;
  final String month;
  final List<ResPropozRow> rows;
  bool approved;
  dynamic filteredRows; // може бути null або список

  ResPropoz({
    required this.id,
    required this.year,
    required this.month,
    required this.rows,
    this.approved = false,
    this.filteredRows,
  });

  factory ResPropoz.fromJson(Map<String, dynamic> json) {
    return ResPropoz(
      id: json['id'],
      year: json['year'],
      month: json['month'],
      rows: (json['rows'] as List)
          .map((e) => ResPropozRow.fromJson(e))
          .toList(),
      approved: json['approved'] ?? false,
      filteredRows: json['filteredRows'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'rows': rows.map((e) => e.toJson()).toList(),
      'approved': approved,
      'filteredRows': filteredRows,
    };
  }
}

class ResPropozRow {
  final String vidomchyiKod;
  final String nameRozporyad;
  String nameVytrat;
  String kekv;
  final int vsogo;
  final Map<String, int> months;
  final String notes;

  ResPropozRow({
    required this.vidomchyiKod,
    required this.nameRozporyad,
    required this.nameVytrat,
    required this.kekv,
    required this.vsogo,
    required this.months,
    this.notes = "",
  });

  factory ResPropozRow.fromJson(Map<String, dynamic> json) {
    return ResPropozRow(
      vidomchyiKod: json['vidomchyiKod'],
      nameRozporyad: json['nameRozporyad'],
      nameVytrat: json['nameVytrat'],
      kekv: json['kekv'],
      vsogo: json['vsogo'],
      months: Map<String, int>.from(json['months']),
      notes: json['notes'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vidomchyiKod': vidomchyiKod,
      'nameRozporyad': nameRozporyad,
      'nameVytrat': nameVytrat,
      'kekv': kekv,
      'vsogo': vsogo,
      'months': months,
      'notes': notes,
    };
  }
}
