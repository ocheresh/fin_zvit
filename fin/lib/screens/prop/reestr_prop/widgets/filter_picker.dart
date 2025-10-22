import 'dart:async';
import 'package:flutter/material.dart';

typedef OnApplyFilter = void Function(String value);

Future<void> showFilterPicker({
  required BuildContext context,
  required String column,
  required List<Map<String, dynamic>>
  rowsScope, // вже відфільтровані «допустимі» рядки
  required String currentValue,
  required OnApplyFilter onApply,
}) async {
  final isNumeric =
      column == 'Всього' ||
      column == 'Номер пропозиції' ||
      column == 'Розрахунки' ||
      (int.tryParse(column) != null);

  final baseSuggestions = _buildSuggestions(column, rowsScope, isNumeric);

  final controller = TextEditingController(text: currentValue);
  String draft = currentValue;

  Timer? _debounce; // ⬅️ дебаунс-таймер

  Future<void> _safePopApply(BuildContext ctx, String v) async {
    _debounce?.cancel();
    Navigator.of(ctx).pop();
    onApply(v.trim());
  }

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final filtered = _filterAndSort(
            baseSuggestions,
            controller.text,
            isNumeric: isNumeric,
          );

          return AlertDialog(
            title: Text(
              'Фільтр: $column',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNumeric)
                    _NumberOpsBar(
                      onPick: (op) {
                        final t = controller.text.trim();
                        final raw = t.replaceAll(RegExp(r'^[<>]=?|=|=='), '');
                        controller.text = '$op$raw';
                        controller.selection = TextSelection.collapsed(
                          offset: controller.text.length,
                        );
                        _debounce?.cancel();
                        setState(() {}); // оператори застосовуємо одразу
                      },
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: isNumeric
                          ? 'Напр.: >1000, 100-200, =3500'
                          : 'Пошук…',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      draft = v;
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 200), () {
                        // оновлюємо підказки лише після паузи у вводі
                        setState(() {});
                      });
                    },
                    onSubmitted: (v) => _safePopApply(ctx, v),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Material(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = filtered[i];
                          return ListTile(
                            dense: true,
                            title: Text(
                              s,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              final v =
                                  isNumeric &&
                                      RegExp(r'^\d+(\.\d+)?$').hasMatch(s)
                                  ? '=$s'
                                  : s;
                              _safePopApply(ctx, v);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _safePopApply(ctx, ''),
                child: const Text('Скинути'),
              ),
              FilledButton(
                onPressed: () => _safePopApply(ctx, controller.text),
                child: const Text('Застосувати'),
              ),
            ],
          );
        },
      );
    },
  );

  _debounce?.cancel(); // на випадок закриття діалогу жестом/беком
}

List<String> _filterAndSort(
  List<String> src,
  String query, {
  required bool isNumeric,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    final base = List<String>.from(src);
    if (isNumeric) {
      base.sort((a, b) => num.parse(a).compareTo(num.parse(b)));
    } else {
      base.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return base;
  }

  bool startsWith(String s) => s.startsWith(q);
  bool contains(String s) => s.contains(q);

  final exact = <String>[];
  final starts = <String>[];
  final mids = <String>[];

  for (final s in src) {
    final sl = s.toLowerCase();
    if (sl == q) {
      exact.add(s);
    } else if (startsWith(sl)) {
      starts.add(s);
    } else if (contains(sl)) {
      mids.add(s);
    }
  }

  int cmp(String a, String b) {
    if (isNumeric) return num.parse(a).compareTo(num.parse(b));
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  exact.sort(cmp);
  starts.sort(cmp);
  mids.sort(cmp);

  return [...exact, ...starts, ...mids];
}

List<String> _buildSuggestions(
  String column,
  List<Map<String, dynamic>> rows,
  bool isNumeric,
) {
  final set = <String>{};

  if (column == 'Особовий рахунок') {
    for (final r in rows) {
      final v = '${r['osobovyi_rahunok'] ?? ''}'.trim();
      if (v.isNotEmpty) set.add(v);
    }
  } else if (column == 'Найменування') {
    for (final r in rows) {
      final v = '${r['naimenuvannia'] ?? ''}'.trim();
      if (v.isNotEmpty) set.add(v);
    }
  } else if (column == 'Код видатків') {
    for (final r in rows) {
      final v = '${r['kod_vydatkiv'] ?? r['код_видатків'] ?? ''}'.trim();
      if (v.isNotEmpty) set.add(v);
    }
  } else if (column == 'Примітка') {
    for (final r in rows) {
      final v = '${r['prymitka'] ?? ''}'.trim();
      if (v.isNotEmpty) set.add(v);
    }
  } else if (column == 'Номер пропозиції') {
    for (final r in rows) {
      final v = r['nomer_propozytsii'];
      if (v != null) set.add('$v');
    }
  } else if (column == 'Розрахунки') {
    for (final r in rows) {
      final num v = (r['rozrah_sum'] ?? r['calc_sum'] ?? 0) as num? ?? 0;
      set.add(v.toString());
    }
  } else if (column == 'Всього') {
    for (final r in rows) {
      final m = (r['m'] as List?)?.cast<num>() ?? const <num>[];
      final sum = m.fold<num>(0, (a, b) => a + b);
      set.add(sum.toString());
    }
  } else {
    final idx = int.tryParse(column);
    if (idx != null && idx >= 1 && idx <= 12) {
      for (final r in rows) {
        final m = (r['m'] as List?)?.cast<num>() ?? const <num>[];
        final v = (idx - 1) < m.length ? m[idx - 1] : 0;
        set.add(v.toString());
      }
    }
  }

  final list = set.toList();
  if (isNumeric) {
    list.sort((a, b) => num.parse(a).compareTo(num.parse(b)));
  } else {
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }
  return list.take(200).toList();
}

class _NumberOpsBar extends StatelessWidget {
  final void Function(String) onPick;
  const _NumberOpsBar({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final ops = ['=', '>', '>=', '<', '<=', 'діапазон a-b'];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: ops.map((o) {
        return ActionChip(
          label: Text(o),
          onPressed: () {
            if (o.contains('діапазон')) {
              onPick('');
            } else {
              onPick(o);
            }
          },
        );
      }).toList(),
    );
  }
}
