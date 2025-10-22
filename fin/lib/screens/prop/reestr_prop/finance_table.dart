import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'utils/constants.dart';
import 'utils/format.dart';
import 'widgets/fit_text.dart';
import 'widgets/highlighted_cell.dart';
import 'widgets/action_buttons.dart';
import 'widgets/summary_row.dart';
import 'widgets/calc_button.dart';
import 'widgets/filter_row.dart';
import 'widgets/add_record_dialog.dart';
import 'widgets/edit_record_dialog.dart';
import 'widgets/confirm_row.dart';
import 'widgets/row_details_dialog.dart';
import 'widgets/calc_dialog.dart';
import 'widgets/month_picker_dialog.dart';

class FinanceTableFixedScaleHighlighted extends StatefulWidget {
  const FinanceTableFixedScaleHighlighted({super.key});

  @override
  State<FinanceTableFixedScaleHighlighted> createState() =>
      _FinanceTableFixedScaleHighlightedState();
}

class _FinanceTableFixedScaleHighlightedState
    extends State<FinanceTableFixedScaleHighlighted> {
  late Future<List<Map<String, dynamic>>> _rowsF;
  List<Map<String, dynamic>> _allRows = [];

  final Map<String, String> _filters = {for (final h in kFinanceHeaders) h: ''};
  late List<bool> _showMonth; // 12 прапорців для 1..12

  @override
  void initState() {
    super.initState();
    final m = DateTime.now().month; // 1..12
    _showMonth = List.generate(12, (i) => (i + 1) >= m); // показуємо m..12
    _rowsF = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final s = await rootBundle.loadString('assets/fin_rows.json');
    final list = (json.decode(s) as List).cast<Map<String, dynamic>>();
    _allRows = List<Map<String, dynamic>>.from(list);
    return _allRows;
  }

  Future<void> _addRecord() async {
    final rec = await showAddRecordDialog(context);
    if (rec == null) return;
    setState(() => _allRows = [rec, ..._allRows]);
  }

  Future<void> _editRecord(int index, Map<String, dynamic> row) async {
    final edited = await showEditRecordDialog(context, row);
    if (edited == null) return;
    setState(() => _allRows[index] = edited);
  }

  Future<void> _confirmDelete(int index, Map<String, dynamic> row) async {
    final months = (row['m'] as List?)?.cast<num>() ?? const <num>[];
    final total = months.fold<num>(0, (a, b) => a + b);

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Підтвердити видалення'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ви дійсно хочете видалити цей запис?'),
            const SizedBox(height: 12),
            ConfirmRow('Особовий рахунок', '${row['osobovyi_rahunok'] ?? ''}'),
            ConfirmRow('Найменування', '${row['naimenuvannia'] ?? ''}'),
            ConfirmRow('Код видатків', '${row['kod_vydatkiv'] ?? ''}'),
            ConfirmRow('Всього', total == 0 ? '' : thousands(total)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Скасувати'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _allRows.removeAt(index));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Запис видалено')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerHighlight = theme.colorScheme.secondaryContainer.withOpacity(
      .75,
    );

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final scale = (w / 1280.0).clamp(0.75, 0.75);

        final headerH = 48.0 * scale;
        final rowH = 42.0 * scale;
        final padH = 6.0 * scale;
        final fsBody = 13.0 * scale;
        final fsHead = 14.0 * scale;
        final iconSize = 16.0 * scale;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _rowsF,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                _allRows.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Помилка: ${snap.error}'));
            }

            final rows = applyFilters(_allRows, _filters);
            final totals = computeTotals(rows);

            return Scaffold(
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _addRecord,
                icon: const Icon(Icons.add),
                label: const Text('Додати запис'),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.3),
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimary.withOpacity(0.9),
              ),
              body: Column(
                children: [
                  // Підсумки
                  SummaryRow(
                    scale: scale,
                    fsBody: fsBody,
                    padH: padH,
                    rowsLength: rows.length,
                    totals: totals,
                  ),

                  // Рядок фільтрів (передаємо visibleMonths)
                  FilterRow(
                    scale: scale,
                    padH: padH,
                    fs: fsBody,
                    current: _filters,
                    allRows: rows,
                    visibleMonths: _showMonth, // ⬅️ важливо
                    onChanged: (col, val) =>
                        setState(() => _filters[col] = val),
                    onClearAll: () {
                      setState(() {
                        for (final h in kFinanceHeaders) {
                          // «Дії» не фільтруємо, «Розрахунки» залишили з фільтром — якщо у вас без фільтра, додайте умову
                          _filters[h] = '';
                        }
                      });
                    },
                  ),

                  // Шапка (видимість місяців врахована)
                  Container(
                    height: headerH,
                    decoration: BoxDecoration(color: headerHighlight),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Фіксовані колонки
                              for (final h in [
                                'Особовий рахунок',
                                'Найменування',
                                'Код видатків',
                                'Всього',
                              ])
                                Expanded(
                                  flex: kFlexMap[h] ?? 6,
                                  child: Container(
                                    height: headerH,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padH,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black12,
                                        ),
                                        bottom: BorderSide(
                                          color: Colors.black26,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                    child: fitTextBold(h, fsHead),
                                  ),
                                ),
                              // Місячні колонки з урахуванням _showMonth
                              for (int i = 0; i < 12; i++)
                                if (_showMonth[i])
                                  Expanded(
                                    flex: kFlexMap['${i + 1}'] ?? 6,
                                    child: Container(
                                      height: headerH,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: padH,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.black12,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.black26,
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                      child: fitTextBold('${i + 1}', fsHead),
                                    ),
                                  ),
                              // Решта фіксованих
                              for (final h in [
                                'Примітка',
                                'Номер пропозиції',
                                'Розрахунки',
                                'Дії',
                              ])
                                Expanded(
                                  flex: kFlexMap[h] ?? 6,
                                  child: Container(
                                    height: headerH,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padH,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black12,
                                        ),
                                        bottom: BorderSide(
                                          color: Colors.black26,
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                    child: fitTextBold(h, fsHead),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Кнопка керування колонками
                        IconButton(
                          tooltip: 'Колонки',
                          icon: const Icon(Icons.view_column),
                          onPressed: () async {
                            final updated = await showDialog<List<bool>>(
                              context: context,
                              builder: (_) =>
                                  MonthPickerDialog(current: _showMonth),
                            );
                            if (updated != null) {
                              setState(() {
                                _showMonth = updated;
                                // очистити фільтри для прихованих місяців
                                for (int i = 0; i < 12; i++) {
                                  if (!_showMonth[i]) {
                                    _filters['${i + 1}'] = '';
                                  }
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Тіло
                  Expanded(
                    child: ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, i) {
                        final r = rows[i];
                        final months =
                            (r['m'] as List?)?.cast<num>() ??
                            List<num>.filled(12, 0);
                        final rowTotal = months.fold<num>(0, (a, b) => a + b);
                        final calcSum = rowTotal; // з місяців

                        String fmt(num? v) =>
                            (v == null || v == 0) ? '' : thousands(v);

                        final cells = <Widget>[
                          highlightedCell(
                            '${r['osobovyi_rahunok'] ?? ''}',
                            'Особовий рахунок',
                            fsBody,
                            padH,
                            Colors.transparent,
                          ),
                          highlightedCell(
                            '${r['naimenuvannia'] ?? ''}',
                            'Найменування',
                            fsBody,
                            padH,
                            Colors.transparent,
                          ),
                          highlightedCell(
                            '${r['kod_vydatkiv'] ?? r['код_видатків'] ?? ''}',
                            'Код видатків',
                            fsBody,
                            padH,
                            Colors.transparent,
                          ),
                          highlightedCell(
                            fmt(rowTotal),
                            'Всього',
                            fsBody,
                            padH,
                            Colors.transparent,
                            alignRight: true,
                          ),

                          // Місяці з урахуванням видимості
                          for (int m = 0; m < 12; m++)
                            if (_showMonth[m])
                              highlightedCell(
                                fmt(m < months.length ? months[m] : 0),
                                '${m + 1}',
                                fsBody,
                                padH,
                                Colors.transparent,
                                alignRight: true,
                              ),

                          highlightedCell(
                            '${r['prymitka'] ?? ''}',
                            'Примітка',
                            fsBody,
                            padH,
                            Colors.transparent,
                          ),
                          highlightedCell(
                            '${r['nomer_propozytsii'] ?? ''}',
                            'Номер пропозиції',
                            fsBody,
                            padH,
                            Colors.transparent,
                            alignRight: true,
                          ),

                          // Розрахунки (кнопка з сумою)
                          calcButtonCell(
                            scale: scale,
                            fs: fsBody,
                            padH: padH,
                            calcSum: calcSum,
                            totalSum: rowTotal,
                            onOpen: () {
                              showCalcDialog(
                                context,
                                kodVydatkiv:
                                    r['kod_vydatkiv'] ?? r['код_видатків'],
                                osobovyiRahunok: r['osobovyi_rahunok'] ?? '',
                                naimenuvannia: r['naimenuvannia'] ?? '',
                                controlSum: rowTotal,
                              );
                            },
                          ),

                          // Дії
                          ActionButtonsCell(
                            flex: kFlexMap['Дії'] ?? 12,
                            fs: fsBody,
                            iconSize: iconSize,
                            padH: padH,
                            bg: Colors.transparent,
                            rowH: rowH,
                            onEdit: () => _editRecord(_allRows.indexOf(r), r),
                            onDelete: () =>
                                _confirmDelete(_allRows.indexOf(r), r),
                          ),
                        ];

                        return InkWell(
                          onTap: () => showRowDetailsDialog(context, r),
                          child: SizedBox(
                            height: rowH,
                            child: Row(children: cells),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// /// Діалог вибору видимих місяців 1..12
// class _MonthPickerDialog extends StatefulWidget {
//   final List<bool> current;
//   const _MonthPickerDialog({required this.current});

//   @override
//   State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
// }

// class _MonthPickerDialogState extends State<_MonthPickerDialog> {
//   late List<bool> sel;

//   @override
//   void initState() {
//     super.initState();
//     sel = List<bool>.from(widget.current);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Вибір місяців'),
//       content: SizedBox(
//         width: 420,
//         child: Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: List.generate(12, (i) {
//             final label = '${i + 1}';
//             return FilterChip(
//               selected: sel[i],
//               label: Text(label),
//               onSelected: (v) => setState(() => sel[i] = v),
//             );
//           }),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Скасувати'),
//         ),
//         TextButton(
//           onPressed: () {
//             // гарантуємо, що хоч один місяць увімкнено
//             if (!sel.contains(true)) {
//               final m = DateTime.now().month;
//               sel[m - 1] = true;
//             }
//             Navigator.pop(context, sel);
//           },
//           child: const Text('Застосувати'),
//         ),
//       ],
//     );
//   }
// }
