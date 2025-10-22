import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/format.dart';

/// Підсумковий блок у один рядок:
/// показує тільки: "Кількість", "Всього", "1..12"
/// Підпис зверху, значення нижче (у 2 рядки). Без borderRadius.
class SummaryRow extends StatelessWidget {
  final double scale;
  final double fsBody;
  final double padH;
  final int rowsLength;
  final Map<String, String> totals;

  const SummaryRow({
    super.key,
    required this.scale,
    required this.fsBody,
    required this.padH,
    required this.rowsLength,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryStripe = theme.colorScheme.primary;
    final summaryBg = theme.colorScheme.surface;
    final summaryBorder = theme.colorScheme.outlineVariant.withOpacity(.6);

    final double minH = ((60.0 * scale).clamp(48.0, 68.0)).toDouble();
    final double fsTop = ((fsBody * 1.1).clamp(13.0, 16.0)).toDouble();
    final double fsVal = ((fsBody * 1.6).clamp(17.0, 22.0)).toDouble();

    final summaryOrder = <String>[
      'Кількість',
      'Всього',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ];
    final values = <String, String>{
      'Кількість': rowsLength.toString(),
      'Всього': totals['Всього'] ?? '',
      for (var i = 1; i <= 12; i++) '$i': totals['$i'] ?? '',
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        10 * scale,
        12 * scale,
        14 * scale,
      ),
      child: Material(
        elevation: 3,
        color: summaryBg,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(.25),
            border: Border.all(color: summaryBorder, width: 1),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 10 * scale,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: summaryOrder.map((k) {
                final flex = (k == 'Кількість') ? 9 : (k == 'Всього' ? 10 : 6);
                final txt = values[k] ?? '';

                return Expanded(
                  flex: flex,
                  child: Container(
                    height: minH,
                    padding: EdgeInsets.symmetric(horizontal: padH * 1.2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: summaryBorder, width: 0.6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          k == 'Кількість' ? 'Записів' : k,
                          style: TextStyle(
                            fontSize: fsTop,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(.8),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            txt,
                            style: TextStyle(
                              fontSize: fsVal,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
