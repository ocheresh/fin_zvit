// lib/core/models/reestrprop.dart
class ReestrProp {
  final int id;
  final int seqNo; // номер пропозиції; тепер = id
  final String kpkvId;
  final String fundId;
  final int month;
  final String signFirstId;
  final String signSecondId;
  final DateTime? sentDfDate;
  final DateTime? acceptedDfDate;

  ReestrProp({
    required this.id,
    required this.seqNo,
    required this.kpkvId,
    required this.fundId,
    required this.month,
    required this.signFirstId,
    required this.signSecondId,
    this.sentDfDate,
    this.acceptedDfDate,
  });

  static String _s(dynamic v) => v == null ? '' : v.toString();

  factory ReestrProp.fromJson(Map<String, dynamic> j) => ReestrProp(
    id: (j['id'] as num).toInt(),
    seqNo: (j['seq_no'] ?? j['id']) is num
        ? ((j['seq_no'] ?? j['id']) as num).toInt()
        : int.tryParse('${j['seq_no'] ?? j['id']}') ?? 0,
    kpkvId: _s(j['kpkv_id']),
    fundId: _s(j['fund_id']),
    month: (j['month'] as num).toInt(),
    signFirstId: _s(j['sign_first_id']),
    signSecondId: _s(j['sign_second_id']),
    sentDfDate: j['sent_df_date'] == null
        ? null
        : DateTime.parse(j['sent_df_date']),
    acceptedDfDate: j['accepted_df_date'] == null
        ? null
        : DateTime.parse(j['accepted_df_date']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'seq_no': seqNo, // тримаємо співпадіння
    'kpkv_id': kpkvId,
    'fund_id': fundId,
    'month': month,
    'sign_first_id': signFirstId,
    'sign_second_id': signSecondId,
    'sent_df_date': sentDfDate?.toIso8601String().split('T').first,
    'accepted_df_date': acceptedDfDate?.toIso8601String().split('T').first,
  };
}
