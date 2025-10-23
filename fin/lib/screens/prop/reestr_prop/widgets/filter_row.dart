import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/format.dart';
import 'filter_picker.dart';

typedef OnFilterChanged = void Function(String column, String value);

class FilterRow extends StatelessWidget {
  final double scale;
  final double padH;
  final double fs;
  final Map<String, String> current;
  final OnFilterChanged onChanged;
  final List<Map<String, dynamic>> allRows;
  final VoidCallback onClearAll;
  final List<bool>? visibleMonths;

  /// виклик діалогу керування видимістю колонок
  final VoidCallback? onOpenColumns;

  const FilterRow({
    super.key,
    required this.scale,
    required this.padH,
    required this.fs,
    required this.current,
    required this.onChanged,
    required this.allRows,
    required this.onClearAll,
    this.visibleMonths,
    this.onOpenColumns,
  });

  @override
  Widget build(BuildContext context) {
    final chipStyle = TextStyle(fontSize: fs);
    final monthVisible = (visibleMonths == null || visibleMonths!.length != 12)
        ? List<bool>.filled(12, true)
        : visibleMonths!;

    final hasActiveFilters = current.entries.any(
      (e) => e.key != 'Дії' && e.value.trim().isNotEmpty,
    );

    Widget actionsCell() {
      return Expanded(
        flex: kFlexMap['Дії'] ?? 6,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padH / 2,
            vertical: 6 * scale,
          ),
          child: LayoutBuilder(
            builder: (context, cc) {
              final w = cc.maxWidth;
              final splash = (18 * scale).clamp(14, 22).toDouble();

              // дуже мало місця — одна кнопка-меню
              if (w < 90) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<_ActionItem>(
                    tooltip: 'Дії',
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: _ActionItem.columns,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.view_column, size: 18),
                            SizedBox(width: 8),
                            Text('Колонки'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        enabled: hasActiveFilters,
                        value: _ActionItem.clear,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.filter_alt_off, size: 18),
                            SizedBox(width: 8),
                            Text('Скинути фільтри'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (it) {
                      switch (it) {
                        case _ActionItem.columns:
                          onOpenColumns?.call();
                          break;
                        case _ActionItem.clear:
                          if (hasActiveFilters) onClearAll();
                          break;
                      }
                    },
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: null, // іконка слугує тригером PopupMenu
                      // ignore: deprecated_member_use
                      splashRadius: splash,
                    ),
                  ),
                );
              }

              // достатньо місця — дві окремі іконки
              return Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Колонки',
                      onPressed: onOpenColumns,
                      icon: const Icon(Icons.view_column),
                      splashRadius: splash,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Скинути всі фільтри',
                      onPressed: hasActiveFilters ? onClearAll : null,
                      icon: const Icon(Icons.filter_alt_off),
                      splashRadius: splash,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    Widget filterCell(String h) {
      // для «Дії» — спец-комірка
      if (h == 'Дії') return actionsCell();

      // пропускаємо приховані місяці
      final monthIndex = int.tryParse(h);
      if (monthIndex != null) {
        final mi = monthIndex - 1;
        if (mi < 0 || mi > 11 || !monthVisible[mi]) {
          return const SizedBox.shrink();
        }
      }

      final value = (current[h] ?? '').trim();
      final has = value.isNotEmpty;

      return Expanded(
        flex: kFlexMap[h] ?? 6,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padH / 2,
            vertical: 6 * scale,
          ),
          child: InkWell(
            onTap: () async {
              // формуємо допустимі значення з урахуванням інших фільтрів
              final scoped = Map<String, String>.from(current);
              scoped[h] = '';
              final rowsScope = applyFilters(allRows, scoped);

              await showFilterPicker(
                context: context,
                column: h,
                rowsScope: rowsScope,
                currentValue: current[h] ?? '',
                onApply: (v) => onChanged(h, v),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: (36 * scale).clamp(30, 44).toDouble(),
              padding: EdgeInsets.symmetric(horizontal: padH),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26, width: .8),
                color: has
                    ? Theme.of(context).colorScheme.primary.withOpacity(.08)
                    : null,
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: fs + 2),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      has ? value : 'фільтр…',
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: chipStyle.copyWith(
                        color: has
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(.6),
                        fontWeight: has ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (has)
                    IconButton(
                      tooltip: 'Очистити',
                      icon: Icon(Icons.clear, size: fs + 2),
                      onPressed: () => onChanged(h, ''),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      splashRadius: 14,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // будуємо у фіксованому порядку, пропускаючи приховані місяці
    final children = <Widget>[];
    for (final h in kFinanceHeaders) {
      final monthIndex = int.tryParse(h);
      if (monthIndex != null) {
        final mi = monthIndex - 1;
        if (mi < 0 || mi > 11 || !(monthVisible[mi])) continue;
      }
      children.add(filterCell(h));
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26, width: 1)),
      ),
      child: Row(children: children),
    );
  }
}

enum _ActionItem { columns, clear }
