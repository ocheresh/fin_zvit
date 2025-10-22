import 'package:flutter/material.dart';
import '../utils/format.dart'; // thousands()

class CalcItem {
  String direction; // напрям видатків (раніше name)
  String unit;
  double qty;
  double price;

  CalcItem({this.direction = '', this.unit = '', this.qty = 0, this.price = 0});

  double get sum => qty * price;

  CalcItem copy() =>
      CalcItem(direction: direction, unit: unit, qty: qty, price: price);
}

Future<void> showCalcDialog(
  BuildContext context, {
  String? kodVydatkiv, // ← показуємо у заголовку
  String? osobovyiRahunok, // ⬅️ нове
  String? naimenuvannia,
  List<CalcItem>? initial,
  required num controlSum,
}) async {
  final items = (initial ?? <CalcItem>[]).map((e) => e.copy()).toList();
  if (items.isEmpty) {
    items.add(CalcItem(unit: 'шт.', qty: 1, price: 0));
  }

  final size = MediaQuery.of(context).size;
  final screenW = size.width;
  final screenH = size.height;

  // Адаптивні габарити діалогу
  final dialogW = screenW.clamp(420.0, 1100.0);
  final dialogH = (screenH * 0.72).clamp(420.0, 800.0);

  // Масштаб для шрифтів/відступів, щоб у вузьких екранах усе влізло без горизонтального скролу
  final compactFactor = (dialogW / 1100.0).clamp(0.75, 1.0);
  final baseFs = 14.0 * compactFactor;
  final pad = 10.0 * compactFactor;
  final rowH = 44.0 * compactFactor;
  final inputV = 8.0 * compactFactor;
  final inputH = 8.0 * compactFactor;

  double totalSum() => items.fold(0.0, (a, b) => a + b.sum);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        width: dialogW,
        height: dialogH,
        child: StatefulBuilder(
          builder: (context, setState) {
            void addRow() {
              setState(() => items.add(CalcItem(unit: 'шт.')));
            }

            void removeRow(int i) {
              setState(() {
                items.removeAt(i);
                if (items.isEmpty) items.add(CalcItem(unit: 'шт.'));
              });
            }

            InputDecoration deco(String hint) => InputDecoration(
              hintText: hint,
              isDense: true,
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: inputH,
                vertical: inputV,
              ),
            );

            TextStyle headStyle = Theme.of(context).textTheme.titleSmall!
                .copyWith(fontWeight: FontWeight.w700, fontSize: baseFs);

            Widget headerCell(
              String text, {
              TextAlign align = TextAlign.left,
              int flex = 1,
            }) {
              return Expanded(
                flex: flex,
                child: Container(
                  alignment: align == TextAlign.right
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(
                    horizontal: pad,
                    vertical: pad * 0.6,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black26)),
                  ),
                  child: Text(text, style: headStyle),
                ),
              );
            }

            Widget bodyCell({required Widget child, int flex = 1}) {
              return Expanded(
                flex: flex,
                child: Container(
                  height: rowH,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(
                    horizontal: pad,
                    vertical: pad * 0.3,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: child,
                ),
              );
            }

            Widget numField({
              required double value,
              required void Function(double) onChanged,
              TextAlign align = TextAlign.right,
            }) {
              // Контролер створюємо локально — для простоти; курсор виставляємо в кінець
              final controller =
                  TextEditingController(
                      text: value == 0 ? '' : value.toString(),
                    )
                    ..selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: (value == 0 ? '' : value.toString()).length,
                      ),
                    );

              return TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: align,
                style: TextStyle(fontSize: baseFs),
                decoration: deco(''),
                onChanged: (s) {
                  final v = double.tryParse(s.replaceAll(',', '.')) ?? 0.0;
                  onChanged(v);
                },
              );
            }

            Widget textField({
              required String value,
              required void Function(String) onChanged,
              TextAlign align = TextAlign.left,
              String hint = '',
            }) {
              final controller = TextEditingController(text: value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: value.length),
                );
              return TextField(
                controller: controller,
                textAlign: align,
                style: TextStyle(fontSize: baseFs),
                decoration: deco(hint),
                onChanged: onChanged,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Заголовок
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, pad, pad, pad * 0.5),
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Розрахунки — ${kodVydatkiv ?? ''}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: baseFs + 2,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            if (osobovyiRahunok != null &&
                                osobovyiRahunok.isNotEmpty)
                              Text(
                                'Особовий рахунок: $osobovyiRahunok',
                                style: TextStyle(
                                  fontSize: baseFs * 0.95,
                                  color: Colors.grey[700],
                                ),
                              ),
                            if (naimenuvannia != null &&
                                naimenuvannia.isNotEmpty)
                              Text(
                                'Найменування: $naimenuvannia',
                                style: TextStyle(
                                  fontSize: baseFs * 0.95,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: addRow,
                        icon: const Icon(Icons.add),
                        label: Text(
                          'Додати рядок',
                          style: TextStyle(fontSize: baseFs),
                        ),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: pad,
                            vertical: pad * 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Шапка таблиці (адаптивні флекси; без горизонтального скролу)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Row(
                    children: [
                      headerCell('Напрям видатків', flex: 5),
                      headerCell('Од. вим.', flex: 2, align: TextAlign.center),
                      headerCell('Кількість', flex: 3, align: TextAlign.right),
                      headerCell(
                        'Ціна за од.',
                        flex: 3,
                        align: TextAlign.right,
                      ),
                      headerCell('Сума', flex: 3, align: TextAlign.right),
                      headerCell('', flex: 1), // видалити
                    ],
                  ),
                ),

                // Тіло таблиці — тільки вертикальний скрол
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final it = items[i];
                        return Row(
                          children: [
                            bodyCell(
                              flex: 5,
                              child: textField(
                                value: it.direction, // ← порожнє за замовч.
                                onChanged: (v) =>
                                    setState(() => it.direction = v),
                                hint: 'вкажіть напрям…',
                              ),
                            ),
                            bodyCell(
                              flex: 2,
                              child: textField(
                                value: it.unit,
                                onChanged: (v) => setState(() => it.unit = v),
                                align: TextAlign.center,
                              ),
                            ),
                            bodyCell(
                              flex: 3,
                              child: numField(
                                value: it.qty,
                                onChanged: (v) => setState(() => it.qty = v),
                                align: TextAlign.right,
                              ),
                            ),
                            bodyCell(
                              flex: 3,
                              child: numField(
                                value: it.price,
                                onChanged: (v) => setState(() => it.price = v),
                                align: TextAlign.right,
                              ),
                            ),
                            bodyCell(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  it.sum == 0 ? '' : thousands(it.sum),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: baseFs,
                                  ),
                                ),
                              ),
                            ),
                            bodyCell(
                              flex: 1,
                              child: IconButton(
                                tooltip: 'Видалити рядок',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => removeRow(i),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Підсумок + кнопки
                // Підсумок + кнопки
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, pad * 0.6, pad, pad),
                  child: Row(
                    children: [
                      // Лівий блок з двома сумами
                      Builder(
                        builder: (_) {
                          final calc = totalSum();
                          final ctrl = controlSum.toDouble();
                          Color stateColor() {
                            if (calc == ctrl)
                              return Colors.green.withOpacity(.12);
                            if (calc < ctrl)
                              return Colors.lightBlue.withOpacity(.12);
                            return Colors.red.withOpacity(.12);
                          }

                          Widget chip(String title, String value, {Color? bg}) {
                            return Container(
                              decoration: BoxDecoration(
                                color: bg,
                                border: Border.all(color: Colors.black12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: pad,
                                vertical: pad * 0.4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$title: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: baseFs,
                                    ),
                                  ),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: baseFs,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Wrap(
                            spacing: pad,
                            runSpacing: pad * 0.4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              chip('Разом', thousands(calc)),
                              chip(
                                'Контрольна сума',
                                thousands(ctrl),
                                bg: stateColor(),
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'Закрити',
                          style: TextStyle(fontSize: baseFs),
                        ),
                      ),
                      SizedBox(width: pad),
                      FilledButton(
                        onPressed: () {
                          // Navigator.of(ctx).pop(items); // якщо потрібно повертати позиції
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          'Застосувати',
                          style: TextStyle(fontSize: baseFs),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
