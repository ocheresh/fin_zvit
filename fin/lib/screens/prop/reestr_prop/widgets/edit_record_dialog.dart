import 'package:flutter/material.dart';

typedef JsonMap = Map<String, dynamic>;

Future<JsonMap?> showEditRecordDialog(BuildContext context, JsonMap row) async {
  final accCtrl = TextEditingController(
    text: '${row['osobovyi_rahunok'] ?? ''}',
  );
  final nameCtrl = TextEditingController(text: '${row['naimenuvannia'] ?? ''}');
  final codeCtrl = TextEditingController(text: '${row['kod_vydatkiv'] ?? ''}');
  final noteCtrl = TextEditingController(text: '${row['prymitka'] ?? ''}');
  final propCtrl = TextEditingController(
    text: '${row['nomer_propozytsii'] ?? ''}',
  );
  final months = (row['m'] as List?)?.cast<num>() ?? List<num>.filled(12, 0);
  final monthCtrls = List.generate(
    12,
    (i) => TextEditingController(
      text: (i < months.length ? months[i] : 0).toString(),
    ),
  );

  num parseNum(String s) => num.tryParse(s.replaceAll(' ', '')) ?? 0;

  JsonMap buildRecord() {
    final m = monthCtrls.map((c) => parseNum(c.text)).toList();
    return {
      "osobovyi_rahunok": accCtrl.text.trim(),
      "naimenuvannia": nameCtrl.text.trim(),
      "kod_vydatkiv": codeCtrl.text.trim(),
      "m": m,
      "prymitka": noteCtrl.text.trim(),
      "nomer_propozytsii": int.tryParse(propCtrl.text.trim()) ?? 0,
      "dii": row['dii'] ?? ["Видалити", "Редагувати"],
    };
  }

  return showDialog<JsonMap>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final titleFs = Theme.of(ctx).textTheme.titleMedium?.fontSize ?? 16;

      InputDecoration deco(String hint) => InputDecoration(
        isDense: true,
        hintText: hint,
        border: const OutlineInputBorder(),
      );

      Widget labeled(String label, Widget field, {int flex = 1}) => Expanded(
        flex: flex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: titleFs),
            ),
            const SizedBox(height: 6),
            field,
          ],
        ),
      );

      return AlertDialog(
        title: const Text('Редагувати запис'),
        content: SizedBox(
          width: 900,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  labeled(
                    'Особовий рахунок',
                    TextField(controller: accCtrl, decoration: deco('')),
                    flex: 2,
                  ),
                  const SizedBox(width: 12),
                  labeled(
                    'Найменування',
                    TextField(controller: nameCtrl, decoration: deco('')),
                    flex: 2,
                  ),
                  const SizedBox(width: 12),
                  labeled(
                    'Код видатків',
                    TextField(controller: codeCtrl, decoration: deco('')),
                    flex: 2,
                  ),
                  const SizedBox(width: 12),
                  labeled(
                    'Номер пропозиції',
                    TextField(
                      controller: propCtrl,
                      keyboardType: TextInputType.number,
                      decoration: deco(''),
                    ),
                    flex: 1,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Місяці (1..12)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: titleFs,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(12, (i) {
                  return SizedBox(
                    width: 120,
                    child: TextField(
                      controller: monthCtrls[i],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: deco('${i + 1}'),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  labeled(
                    'Примітка',
                    TextField(
                      controller: noteCtrl,
                      decoration: deco(''),
                      minLines: 1,
                      maxLines: 2,
                    ),
                    flex: 4,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(flex: 2, child: SizedBox.shrink()),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(buildRecord()),
            child: const Text('Зберегти'),
          ),
        ],
      );
    },
  );
}
