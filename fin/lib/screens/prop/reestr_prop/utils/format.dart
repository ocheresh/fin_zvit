import 'constants.dart';

String thousands(num v) {
  final s = v.toStringAsFixed(0);
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    b.write(s[i]);
    if (idx > 1 && idx % 3 == 1) b.write(' ');
  }
  return b.toString();
}

bool isNumericColumn(String h) => h == 'Всього' || (int.tryParse(h) != null);

// підрахунок підсумків для "Всього" та 1..12
Map<String, String> computeTotals(List<Map<String, dynamic>> rows) {
  final monthSums = List<num>.filled(12, 0);
  for (final r in rows) {
    final m = (r['m'] as List?)?.cast<num>() ?? const [];
    for (var i = 0; i < 12; i++) {
      if (i < m.length) monthSums[i] += m[i];
    }
  }
  final totalAll = monthSums.fold<num>(0, (a, b) => a + b);
  final res = <String, String>{};
  res['Всього'] = totalAll == 0 ? '' : thousands(totalAll);
  for (var i = 0; i < 12; i++) {
    final key = '${i + 1}';
    res[key] = monthSums[i] == 0 ? '' : thousands(monthSums[i]);
  }
  return res;
}

/// ====== ФІЛЬТРАЦІЯ ======
/// Підтримувані форми для чисел: =123, >123, <123, >=123, <=123, 100-200, просто 123 (як =123)
bool _numMatches(num val, String qRaw) {
  final q = qRaw.replaceAll(' ', '');
  if (q.isEmpty) return true;

  // діапазон a-b
  final range = RegExp(r'^(\d+)-(\d+)$');
  final m = range.firstMatch(q);
  if (m != null) {
    final a = num.parse(m.group(1)!);
    final b = num.parse(m.group(2)!);
    final lo = a < b ? a : b, hi = a > b ? a : b;
    return val >= lo && val <= hi;
  }

  // префікси порівнянь
  final ops = ['>=', '<=', '>', '<', '=', '=='];
  for (final op in ops) {
    if (q.startsWith(op)) {
      final n = num.tryParse(q.substring(op.length));
      if (n == null) return true;
      switch (op) {
        case '>=':
          return val >= n;
        case '<=':
          return val <= n;
        case '>':
          return val > n;
        case '<':
          return val < n;
        default:
          return val == n;
      }
    }
  }

  // просто число => рівність
  final n = num.tryParse(q);
  if (n != null) return val == n;

  return true; // якщо не розпізнано — не фільтруємо
}

bool _strMatches(String? value, String qRaw) {
  final q = qRaw.trim().toLowerCase();
  if (q.isEmpty) return true;
  final s = (value ?? '').toLowerCase();
  return s.contains(q);
}

/// Повертає відфільтрований список згідно з мапою фільтрів по заголовкам
List<Map<String, dynamic>> applyFilters(
  List<Map<String, dynamic>> rows,
  Map<String, String> filters,
) {
  if (filters.values.every((v) => (v.trim().isEmpty))) return rows;

  return rows.where((r) {
    // роу-метрики
    final months = (r['m'] as List?)?.cast<num>() ?? const <num>[];
    final rowTotal = months.fold<num>(0, (a, b) => a + b);
    final calcSum = (r['rozrah_sum'] ?? r['calc_sum'] ?? 0) as num? ?? 0;

    for (final e in filters.entries) {
      final col = e.key;
      final q = e.value.trim();
      if (q.isEmpty) continue;

      bool ok = true;
      switch (col) {
        case 'Особовий рахунок':
          ok = _strMatches(r['osobovyi_rahunok']?.toString(), q);
          break;
        case 'Найменування':
          ok = _strMatches(r['naimenuvannia']?.toString(), q);
          break;
        case 'Код видатків':
          ok = _strMatches(r['kod_vydatkiv']?.toString(), q);
          break;
        case 'Розрахунки':
          ok = _numMatches(calcSum, q);
          break;
        case 'Всього':
          ok = _numMatches(rowTotal, q);
          break;
        case 'Примітка':
          ok = _strMatches(r['prymitka']?.toString(), q);
          break;
        case 'Номер пропозиції':
          ok = _numMatches(num.tryParse('${r['nomer_propozytsii']}') ?? 0, q);
          break;
        case 'Дії':
          ok = true;
          break;
        default:
          // Місяці 1..12
          final idx = int.tryParse(col);
          if (idx != null && idx >= 1 && idx <= 12) {
            final v = (idx - 1) < months.length ? months[idx - 1] : 0;
            ok = _numMatches(v, q);
          }
      }

      if (!ok) return false; // AND логіка
    }
    return true;
  }).toList();
}
