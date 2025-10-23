class ProposalCalcItem {
  final String osobovyiRahunok; // особовий рахунок
  final String naimenuvannia; // найменування
  final String kodVydatkiv; // код видатків
  final String naimenVytrat; // найменування витрат
  final String odVymiru; // одиниця виміру
  final double kilkist; // кількість
  final double tsinaZaOdynts; // ціна за одиницю
  final String nomerPropozytsii; // номер пропозиції

  const ProposalCalcItem({
    required this.osobovyiRahunok,
    required this.naimenuvannia,
    required this.kodVydatkiv,
    required this.naimenVytrat,
    required this.odVymiru,
    required this.kilkist,
    required this.tsinaZaOdynts,
    required this.nomerPropozytsii,
  });

  double get vsogo => kilkist * tsinaZaOdynts;

  factory ProposalCalcItem.fromJson(Map<String, dynamic> j) => ProposalCalcItem(
    osobovyiRahunok: j['osobovyiRahunok'] as String,
    naimenuvannia: j['naimenuvannia'] as String,
    kodVydatkiv: j['kodVydatkiv'] as String,
    naimenVytrat: j['naimenVytrat'] as String,
    odVymiru: j['odVymiru'] as String,
    kilkist: (j['kilkist'] as num).toDouble(),
    tsinaZaOdynts: (j['tsinaZaOdynts'] as num).toDouble(),
    nomerPropozytsii: j['nomerPropozytsii'] as String,
  );

  Map<String, dynamic> toJson() => {
    'osobovyiRahunok': osobovyiRahunok,
    'naimenuvannia': naimenuvannia,
    'kodVydatkiv': kodVydatkiv,
    'naimenVytrat': naimenVytrat,
    'odVymiru': odVymiru,
    'kilkist': kilkist,
    'tsinaZaOdynts': tsinaZaOdynts,
    'nomerPropozytsii': nomerPropozytsii,
  };
}
