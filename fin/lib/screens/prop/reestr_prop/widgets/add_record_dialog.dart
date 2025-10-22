import 'package:flutter/material.dart';

typedef JsonMap = Map<String, dynamic>;

Future<JsonMap?> showAddRecordDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();

  final accCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final propCtrl = TextEditingController();
  final monthCtrls = List.generate(12, (_) => TextEditingController());

  num parseNum(String s) => num.tryParse(s.replaceAll(' ', '')) ?? 0;
  num calcTotal() =>
      monthCtrls.fold<num>(0, (a, c) => a + (num.tryParse(c.text) ?? 0));

  JsonMap buildRecord() {
    final m = monthCtrls.map((c) => parseNum(c.text)).toList();
    return {
      "osobovyi_rahunok": accCtrl.text.trim(),
      "naimenuvannia": nameCtrl.text.trim(),
      "kod_vydatkiv": codeCtrl.text.trim(),
      "m": m,
      "prymitka": noteCtrl.text.trim(),
      "nomer_propozytsii": int.tryParse(propCtrl.text.trim()) ?? 0,
      // "rozrah_sum": calcTotal(), // можна зберігати, але не обов'язково
      "dii": ["Видалити", "Редагувати"],
    };
  }

  return showDialog<JsonMap>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final titleFs = Theme.of(ctx).textTheme.titleMedium?.fontSize ?? 16;

          InputDecoration deco(String hint) => InputDecoration(
            isDense: true,
            hintText: hint,
            border: const OutlineInputBorder(),
          );

          Widget labeled(String label, Widget field, {int flex = 1}) =>
              Expanded(
                flex: flex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: titleFs,
                      ),
                    ),
                    const SizedBox(height: 6),
                    field,
                  ],
                ),
              );

          return AlertDialog(
            title: const Text('Додати запис'),
            content: SizedBox(
              width: 900,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      labeled(
                        'Особовий рахунок',
                        TextFormField(
                          controller: accCtrl,
                          decoration: deco('напр. 50212'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Обовʼязково'
                              : null,
                        ),
                        flex: 2,
                      ),
                      const SizedBox(width: 12),
                      labeled(
                        'Найменування',
                        TextFormField(
                          controller: nameCtrl,
                          decoration: deco('напр. А0135'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Обовʼязково'
                              : null,
                        ),
                        flex: 2,
                      ),
                      const SizedBox(width: 12),
                      labeled(
                        'Код видатків',
                        TextFormField(
                          controller: codeCtrl,
                          decoration: deco('напр. 2210.030/4'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Обовʼязково'
                              : null,
                        ),
                        flex: 2,
                      ),
                      const SizedBox(width: 12),
                      labeled(
                        'Номер пропозиції',
                        TextFormField(
                          controller: propCtrl,
                          keyboardType: TextInputType.number,
                          decoration: deco('напр. 150'),
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
                          onChanged: (_) => setState(() {}),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      labeled(
                        'Примітка',
                        TextFormField(
                          controller: noteCtrl,
                          decoration: deco('текст примітки'),
                          minLines: 1,
                          maxLines: 2,
                        ),
                        flex: 4,
                      ),
                      const SizedBox(width: 12),
                      // Місце під інші поля у майбутньому (суми не показуємо)
                      Expanded(flex: 2, child: const SizedBox.shrink()),
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
                onPressed: () {
                  if ((formKey.currentState?.validate() ?? true) == false)
                    return;
                  Navigator.of(ctx).pop(buildRecord());
                },
                child: const Text('Додати'),
              ),
            ],
          );
        },
      );
    },
  );
}
