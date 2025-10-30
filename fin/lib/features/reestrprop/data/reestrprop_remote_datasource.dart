import '../../../core/reposetories/reestrprop_repository.dart';
import '../../../core/models/reestrprop.dart';

class ReestrPropRemoteDataSource {
  final ReestrPropRepository repo;
  ReestrPropRemoteDataSource(this.repo);

  Future<List<ReestrProp>> fetchAll() => repo.list();

  Future<ReestrProp> createItem({
    required String kpkvId,
    required String fundId,
    required int month,
    required String signFirstId,
    required String signSecondId,
    DateTime? sentDf,
    DateTime? acceptedDf,
  }) => repo.create(
    kpkvId: kpkvId,
    fundId: fundId,
    month: month,
    signFirstId: signFirstId,
    signSecondId: signSecondId,
    sentDf: sentDf,
    acceptedDf: acceptedDf,
  );

  Future<ReestrProp> updateItem(int id, Map<String, dynamic> patch) =>
      repo.update(id, patch);
  Future<void> deleteItem(int id) => repo.delete(id);
}
