import 'package:flutter/material.dart';
import '../utils/format.dart'; // thousands()

Future<void> showRowDetailsDialog(
  BuildContext context,
  Map<String, dynamic> row,
) async {
  final months = (row['m'] as List?)?.cast<num>() ?? List<num>.filled(12, 0);
  final total = months.fold<num>(0, (a, b) => a + b);

  Color chipColor() {
    final calcSum = total; // якщо буде інший — підстав тут
    if (calcSum == total) return Colors.green.withOpacity(.12);
    if (calcSum < total) return Colors.lightBlue.withOpacity(.12);
    return Colors.red.withOpacity(.12);
  }

  String fmt(num? v) => (v == null || v == 0) ? '' : thousands(v);

  // Обираємо цільову ширину діалогу без LayoutBuilder
  final screenW = MediaQuery.of(context).size.width;
  final dialogW = screenW.clamp(360.0, 960.0);
  final isNarrow = dialogW < 560.0;

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Деталі запису'),
      // 🔒 Фіксуємо ширину через SizedBox — жодних intrinsic вимірів для LayoutBuilder
      content: SizedBox(
        width: dialogW,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _detailGrid(isNarrow, [
                ['Особовий рахунок', '${row['osobovyi_rahunok'] ?? ''}'],
                ['Найменування', '${row['naimenuvannia'] ?? ''}'],
                [
                  'Код видатків',
                  '${row['kod_vydatkiv'] ?? row['код_видатків'] ?? ''}',
                ],
                ['Номер пропозиції', '${row['nomer_propozytsii'] ?? ''}'],
              ]),
              const SizedBox(height: 12),
              _detailBlock('Примітка', '${row['prymitka'] ?? ''}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _chipKV('Всього', fmt(total)),
                  Container(
                    decoration: BoxDecoration(
                      color: chipColor(),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calculate_outlined, size: 16),
                        const SizedBox(width: 6),
                        const Text('Розрахунки:'),
                        const SizedBox(width: 6),
                        Text(
                          fmt(total),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _monthsGrid(months, fmt),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Закрити'),
        ),
      ],
    ),
  );
}

Widget _chipKV(String k, String v) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

// ⬇️ БЕЗ LayoutBuilder. Передаємо isNarrow ззовні.
Widget _detailGrid(bool isNarrow, List<List<String>> kv) {
  final rows = <Widget>[];
  for (int i = 0; i < kv.length; i += isNarrow ? 1 : 2) {
    final left = kv[i];
    final right = (i + 1 < kv.length) ? kv[i + 1] : null;
    rows
      ..add(
        Row(
          children: [
            Expanded(child: _detailBlock(left[0], left[1])),
            if (right != null) ...[
              const SizedBox(width: 12),
              Expanded(child: _detailBlock(right[0], right[1])),
            ],
          ],
        ),
      )
      ..add(const SizedBox(height: 8));
  }
  if (rows.isNotEmpty) rows.removeLast();
  return Column(children: rows);
}

Widget _detailBlock(String label, String value) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SelectableText(
          value.isEmpty ? '—' : value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ),
  );
}

Widget _monthsGrid(List<num> months, String Function(num?) fmt) {
  List<Widget> row(int start) => List.generate(6, (i) {
    final idx = start + i;
    final label = '${idx + 1}';
    final val = idx < months.length ? months[idx] : 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(fmt(val), style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  });

  return Column(
    children: [
      Row(children: row(0)),
      const SizedBox(height: 8),
      Row(children: row(6)),
    ],
  );
}
