import 'package:fin/core/api/api_service.dart';
import 'package:fin/core/models/signer.dart';

class SignersRemoteDataSource {
  final ApiService api;
  static const prefix = '/api/v1/signers';
  SignersRemoteDataSource(this.api);

  Future<List<Signer>> getAll() async {
    final res = await api.get(prefix);
    return (res as List).map((e) => Signer.fromJson(e)).toList();
  }

  Future<Signer> create(Signer s) async {
    final body = s.toJson()..remove('id'); // id генерує бекенд
    final res = await api.post(prefix, body);
    return Signer.fromJson(res);
  }

  Future<Signer> update(Signer s) async {
    final res = await api.put('$prefix/${s.id}', s.toJson());
    return Signer.fromJson(res);
  }

  Future<void> delete(String id) async {
    await api.delete('$prefix/$id');
  }
}
