import 'package:fin/core/models/signer.dart';
import '../../features/signers/data/signers_remote_datasource.dart';

class SignersRepository {
  final SignersRemoteDataSource remote;
  SignersRepository(this.remote);

  Future<List<Signer>> load() => remote.getAll();
  Future<Signer> create(Signer s) => remote.create(s);
  Future<Signer> update(Signer s) => remote.update(s);
  Future<void> delete(String id) => remote.delete(id);
}
