import '../models/reestrprop.dart';
import '../api/api_service.dart';

class ReestrPropRepository {
  final ApiService api;
  ReestrPropRepository(this.api);

  static const String _prefix = '/api/v1/reestrprop';

  Future<List<ReestrProp>> list() async {
    final r = await api.get(_prefix);
    final arr = r as List;
    return arr.map((e) => ReestrProp.fromJson(e)).toList();
  }

  Future<ReestrProp> create({
    required String kpkvId,
    required String fundId,
    required int month,
    required String signFirstId,
    required String signSecondId,
    DateTime? sentDf,
    DateTime? acceptedDf,
  }) async {
    final body = {
      'kpkv_id': kpkvId,
      'fund_id': fundId,
      'month': month,
      'sign_first_id': signFirstId,
      'sign_second_id': signSecondId,
      'sent_df_date': sentDf?.toIso8601String().split('T').first,
      'accepted_df_date': acceptedDf?.toIso8601String().split('T').first,
    };
    final r = await api.post(_prefix, body);
    return ReestrProp.fromJson(r);
  }

  Future<ReestrProp> update(int id, Map<String, dynamic> patch) async {
    final r = await api.put('$_prefix/$id', patch);
    return ReestrProp.fromJson(r);
  }

  Future<void> delete(int id) async {
    await api.delete('$_prefix/$id');
  }
}
