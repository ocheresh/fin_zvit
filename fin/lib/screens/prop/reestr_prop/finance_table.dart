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

class FinanceTableFixedScaleHighlighted extends StatefulWidget {
  const FinanceTableFixedScaleHighlighted({super.key});

  @override
  State<FinanceTableFixedScaleHighlighted> createState() =>
      _FinanceTableFixedScaleHighlightedState();
}

class _FinanceTableFixedScaleHighlightedState
    extends State<FinanceTableFixedScaleHighlighted> {
  late Future<List<Map<String, dynamic>>> _rowsF;

  // СТАН ФІЛЬТРІВ (по всіх заголовках)
  final Map<String, String> _filters = {for (final h in kFinanceHeaders) h: ''};

  @override
  void initState() {
    super.initState();
    _rowsF = _load(); // локальне завантаження з assets
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final s = await rootBundle.loadString('assets/fin_rows.json');
    return (json.decode(s) as List).cast<Map<String, dynamic>>();
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

        // фіксований мінімальний масштаб для всіх елементів
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
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Помилка: ${snap.error}'));
            }

            // усі рядки
            final allRows = snap.data ?? [];
            // застосувати фільтри
            final rows = applyFilters(allRows, _filters);
            // підрахунок підсумків по ВІДФІЛЬТРОВАНИХ рядках
            final totals = computeTotals(rows);

            return Column(
              children: [
                // ПІДСУМКИ (над таблицею)
                SummaryRow(
                  scale: scale,
                  fsBody: fsBody,
                  padH: padH,
                  rowsLength: rows.length,
                  totals: totals,
                ),

                // СТІКІ-ШАПКА (з підсвіткою)
                Container(
                  height: headerH,
                  decoration: BoxDecoration(color: headerHighlight),
                  child: Row(
                    children: kFinanceHeaders.map((h) {
                      return Expanded(
                        flex: kFlexMap[h] ?? 6,
                        child: Container(
                          height: headerH,
                          padding: EdgeInsets.symmetric(horizontal: padH),
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.black12),
                              bottom: BorderSide(
                                color: Colors.black26,
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: fitTextBold(h, fsHead),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // РЯДОК ФІЛЬТРІВ (під шапкою)
                FilterRow(
                  scale: scale,
                  padH: padH,
                  fs: fsBody,
                  current: _filters,
                  onChanged: (col, val) {
                    setState(() {
                      _filters[col] = val;
                    });
                  },
                ),

                // ОСНОВНА ТАБЛИЦЯ (тільки вертикальний скрол)
                Expanded(
                  child: ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      final months =
                          (r['m'] as List?)?.cast<num>() ??
                          List<num>.filled(12, 0);
                      final rowTotal = months.fold<num>(0, (a, b) => a + b);
                      final calcSum =
                          (r['rozrah_sum'] ?? r['calc_sum'] ?? 0) as num? ?? 0;

                      String fmt(num? v) =>
                          (v == null || v == 0) ? '' : thousands(v);

                      // ПОРЯДОК КОЛОНОК відповідає kFinanceHeaders
                      final cells = <Widget>[
                        // Особовий рахунок
                        highlightedCell(
                          '${r['osobovyi_rahunok'] ?? ''}',
                          'Особовий рахунок',
                          fsBody,
                          padH,
                          Colors.transparent,
                        ),
                        // Найменування
                        highlightedCell(
                          '${r['naimenuvannia'] ?? ''}',
                          'Найменування',
                          fsBody,
                          padH,
                          Colors.transparent,
                        ),
                        // Код видатків
                        highlightedCell(
                          '${r['kod_vydatkiv'] ?? r['код_видатків'] ?? ''}',
                          'Код видатків',
                          fsBody,
                          padH,
                          Colors.transparent,
                        ),

                        // Всього (з 1..12)
                        highlightedCell(
                          fmt(rowTotal),
                          'Всього',
                          fsBody,
                          padH,
                          Colors.transparent,
                          alignRight: true,
                        ),
                        // Місяці 1..12
                        ...List.generate(12, (m) {
                          final key = '${m + 1}';
                          final v = m < months.length ? months[m] : 0;
                          return highlightedCell(
                            fmt(v),
                            key,
                            fsBody,
                            padH,
                            Colors.transparent,
                            alignRight: true,
                          );
                        }),
                        // Примітка
                        highlightedCell(
                          '${r['prymitka'] ?? ''}',
                          'Примітка',
                          fsBody,
                          padH,
                          Colors.transparent,
                        ),
                        // Номер пропозиції
                        highlightedCell(
                          '${r['nomer_propozytsii'] ?? ''}',
                          'Номер пропозиції',
                          fsBody,
                          padH,
                          Colors.transparent,
                          alignRight: true,
                        ),

                        // Розрахунки (кнопка з підсвіткою за правилом)
                        calcButtonCell(
                          scale: scale,
                          fs: fsBody,
                          padH: padH,
                          calcSum: calcSum,
                          totalSum: rowTotal,
                        ),
                        // Дії
                        ActionButtonsCell(
                          flex: kFlexMap['Дії'] ?? 12,
                          fs: fsBody,
                          iconSize: iconSize,
                          padH: padH,
                          bg: Colors.transparent,
                          rowH: rowH,
                        ),
                      ];

                      return SizedBox(
                        height: rowH,
                        child: Row(children: cells),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
