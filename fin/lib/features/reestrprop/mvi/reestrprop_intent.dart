sealed class ReestrPropIntent {
  const ReestrPropIntent();
}

class RPLoad extends ReestrPropIntent {
  const RPLoad();
}

class RPCreate extends ReestrPropIntent {
  final String kpkvId, fundId, signFirstId, signSecondId; // ← String
  final int month; // ← int

  final DateTime? sentDf, acceptedDf;
  const RPCreate({
    required this.kpkvId,
    required this.fundId,
    required this.month,
    required this.signFirstId,
    required this.signSecondId,
    this.sentDf,
    this.acceptedDf,
  });
}

class RPUpdate extends ReestrPropIntent {
  final int id;
  final Map<String, dynamic> patch;
  const RPUpdate(this.id, this.patch);
}

class RPDelete extends ReestrPropIntent {
  final int id;
  const RPDelete(this.id);
}
