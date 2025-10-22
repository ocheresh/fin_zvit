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

  /// Видимість місяців 1..12; якщо null — вважаємо, що всі 12 видимі.
  final List<bool>? visibleMonths;

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
  });

  @override
  Widget build(BuildContext context) {
    final chipStyle = TextStyle(fontSize: fs);
    final monthVisible = (visibleMonths == null || visibleMonths!.length != 12)
        ? List<bool>.filled(12, true)
        : visibleMonths!;

    // є активні фільтри (усі, окрім «Дії»)
    final hasActiveFilters = current.entries.any(
      (e) => e.key != 'Дії' && e.value.trim().isNotEmpty,
    );

    Widget cell(String h) {
      // «Дії» — тільки кнопка "Скинути всі"
      if (h == 'Дії') {
        return Expanded(
          flex: kFlexMap[h] ?? 6,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padH / 2,
              vertical: 6 * scale,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Скинути всі фільтри',
                onPressed: hasActiveFilters ? onClearAll : null,
                icon: const Icon(Icons.filter_alt_off),
                splashRadius: (18 * scale).clamp(16, 22).toDouble(),
              ),
            ),
          ),
        );
      }

      // якщо це один із місяців і він прихований — нічого не рендеримо
      final monthIndex = int.tryParse(h); // 1..12 або null
      if (monthIndex != null) {
        final mi = monthIndex - 1; // 0..11
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
              // Будуємо допустимі значення з урахуванням інших фільтрів
              final scoped = Map<String, String>.from(current);
              scoped[h] = ''; // поточний — тимчасово прибираємо
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
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      has ? value : 'фільтр…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Будуємо рядок у фіксованому порядку з constants, але пропускаємо приховані місяці
    final children = <Widget>[];
    for (final h in kFinanceHeaders) {
      final monthIndex = int.tryParse(h);
      if (monthIndex != null) {
        final mi = monthIndex - 1;
        if (mi < 0 || mi > 11 || !monthVisible[mi]) {
          continue; // пропускаємо фільтр прихованого місяця
        }
      }
      children.add(cell(h));
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26, width: 1)),
      ),
      child: Row(children: children),
    );
  }
}
