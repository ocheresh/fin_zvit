import 'package:flutter/foundation.dart';
import '../data/proposal_calc_repository.dart';
import '../models/proposal_calc_item.dart';

class ProposalCalcViewModel extends ChangeNotifier {
  final ProposalCalcRepository repo;
  ProposalCalcViewModel({required this.repo});

  List<ProposalCalcItem> _all = [];
  List<ProposalCalcItem> _filtered = [];

  // фільтри (каскадні)
  Map<String, String> filters = {
    'osobovyiRahunok': '',
    'naimenuvannia': '',
    'kodVydatkiv': '',
    'naimenVytrat': '',
    'odVymiru': '',
    'kilkist': '',
    'tsinaZaOdynts': '',
    'nomerPropozytsii': '',
  };

  List<ProposalCalcItem> get items => _filtered;

  Future<void> init() async {
    _all = await repo.load();
    _applyFilters(); // початково показуємо всі дані
  }

  void setFilter(String key, String value) {
    filters[key] = value;
    _applyFilters();
  }

  void clearFilters() {
    filters.updateAll((key, value) => '');
    _applyFilters();
  }

  void _applyFilters() {
    bool like(String s, String q) =>
        q.trim().isEmpty || s.toLowerCase().contains(q.trim().toLowerCase());

    bool matchNum(double v, String q) {
      final t = q.trim();
      if (t.isEmpty) return true;
      double? p(String s) => double.tryParse(s.replaceAll(',', '.'));
      if (t.startsWith('>=')) return v >= (p(t.substring(2)) ?? v);
      if (t.startsWith('<=')) return v <= (p(t.substring(2)) ?? v);
      if (t.startsWith('>')) return v > (p(t.substring(1)) ?? v);
      if (t.startsWith('<')) return v < (p(t.substring(1)) ?? v);
      if (t.startsWith('=')) return v == (p(t.substring(1)) ?? v);
      return v.toString().contains(t);
    }

    _filtered = _all.where((it) {
      var ok = true;
      ok &= like(it.osobovyiRahunok, filters['osobovyiRahunok']!);
      ok &= like(it.naimenuvannia, filters['naimenuvannia']!);
      ok &= like(it.kodVydatkiv, filters['kodVydatkiv']!);
      ok &= like(it.naimenVytrat, filters['naimenVytrat']!);
      ok &= like(it.odVymiru, filters['odVymiru']!);
      ok &= matchNum(it.kilkist, filters['kilkist']!);
      ok &= matchNum(it.tsinaZaOdynts, filters['tsinaZaOdynts']!);
      ok &= like(it.nomerPropozytsii, filters['nomerPropozytsii']!);
      return ok;
    }).toList();

    notifyListeners();
  }

  // Підсумки
  double get totalVsogo => _filtered.fold(0.0, (s, it) => s + it.vsogo);
  int get count => _filtered.length;

  /// Каскадні опції для dropdown’ів (беруться з _all з урахуванням інших фільтрів)
  List<String> optionsFor(String fieldKey) {
    final saved = filters[fieldKey]!;
    filters[fieldKey] = ''; // тимчасово прибираємо цей фільтр
    bool like(String s, String q) =>
        q.trim().isEmpty || s.toLowerCase().contains(q.trim().toLowerCase());
    bool matchNum(double v, String q) {
      final t = q.trim();
      if (t.isEmpty) return true;
      double? p(String s) => double.tryParse(s.replaceAll(',', '.'));
      if (t.startsWith('>=')) return v >= (p(t.substring(2)) ?? v);
      if (t.startsWith('<=')) return v <= (p(t.substring(2)) ?? v);
      if (t.startsWith('>')) return v > (p(t.substring(1)) ?? v);
      if (t.startsWith('<')) return v < (p(t.substring(1)) ?? v);
      if (t.startsWith('=')) return v == (p(t.substring(1)) ?? v);
      return v.toString().contains(t);
    }

    final base = _all.where((it) {
      var ok = true;
      ok &= like(it.osobovyiRahunok, filters['osobovyiRahunok']!);
      ok &= like(it.naimenuvannia, filters['naimenuvannia']!);
      ok &= like(it.kodVydatkiv, filters['kodVydatkiv']!);
      ok &= like(it.naimenVytrat, filters['naimenVytrat']!);
      ok &= like(it.odVymiru, filters['odVymiru']!);
      ok &= matchNum(it.kilkist, filters['kilkist']!);
      ok &= matchNum(it.tsinaZaOdynts, filters['tsinaZaOdynts']!);
      ok &= like(it.nomerPropozytsii, filters['nomerPropozytsii']!);
      return ok;
    });

    String pick(ProposalCalcItem x) {
      switch (fieldKey) {
        case 'osobovyiRahunok':
          return x.osobovyiRahunok;
        case 'naimenuvannia':
          return x.naimenuvannia;
        case 'kodVydatkiv':
          return x.kodVydatkiv;
        case 'naimenVytrat':
          return x.naimenVytrat;
        case 'odVymiru':
          return x.odVymiru;
        case 'nomerPropozytsii':
          return x.nomerPropozytsii;
        case 'kilkist':
          return x.kilkist.toStringAsFixed(2);
        case 'tsinaZaOdynts':
          return x.tsinaZaOdynts.toStringAsFixed(2);
        default:
          return '';
      }
    }

    final set = <String>{};
    for (final it in base) {
      final v = pick(it);
      if (v.isNotEmpty) set.add(v);
    }

    filters[fieldKey] = saved; // повертаємо фільтр
    final list = set.toList()..sort((a, b) => a.compareTo(b));
    return list;
  }
}
