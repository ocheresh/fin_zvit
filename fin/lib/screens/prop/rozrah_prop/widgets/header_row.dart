// lib/rozrah_prop/widgets/header_row.dart
import 'package:flutter/material.dart';
import 'table_cells.dart';

class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: FlexCols.osob,
          child: const CellBox(header: true, child: SizedBox()).copyWith(
            child: cellText('Особовий рахунок', weight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: FlexCols.name,
          child: const CellBox(
            header: true,
            child: SizedBox(),
          ).copyWith(child: cellText('Найменування', weight: FontWeight.w600)),
        ),
        Expanded(
          flex: FlexCols.kekv,
          child: const CellBox(
            header: true,
            child: SizedBox(),
          ).copyWith(child: cellText('Код видатків', weight: FontWeight.w600)),
        ),
        Expanded(
          flex: FlexCols.vytr,
          child: const CellBox(header: true, child: SizedBox()).copyWith(
            child: cellText('Найменування витрат', weight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: FlexCols.unit,
          child: const CellBox(
            header: true,
            child: SizedBox(),
          ).copyWith(child: cellText('Од. вим.', weight: FontWeight.w600)),
        ),
        Expanded(
          flex: FlexCols.qty,
          child: const CellBox(header: true, child: SizedBox()).copyWith(
            child: cellText(
              'Кільк.',
              align: TextAlign.right,
              weight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: FlexCols.price,
          child: const CellBox(header: true, child: SizedBox()).copyWith(
            child: cellText(
              'Ціна',
              align: TextAlign.right,
              weight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: FlexCols.sum,
          child: const CellBox(header: true, child: SizedBox()).copyWith(
            child: cellText(
              'Всього',
              align: TextAlign.right,
              weight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: FlexCols.prop,
          child: const CellBox(
            header: true,
            child: SizedBox(),
          ).copyWith(child: cellText('№ проп.', weight: FontWeight.w600)),
        ),
        Expanded(
          flex: FlexCols.actions,
          child:
              const CellBox(
                header: true,
                alignment: Alignment.center,
                child: SizedBox(),
              ).copyWith(
                child: cellText(
                  'Дії',
                  align: TextAlign.center,
                  weight: FontWeight.w600,
                ),
              ),
        ),
      ],
    );
  }
}

// невеликий extension, щоб зручно міняти лише child при збереженні стилю
extension _CellBoxCopy on CellBox {
  CellBox copyWith({
    Widget? child,
    bool? header,
    Alignment? alignment,
    Color? borderColor,
    Color? headerBg,
  }) => CellBox(
    child: child ?? this.child,
    header: header ?? this.header,
    alignment: alignment ?? this.alignment,
    borderColor: borderColor ?? this.borderColor,
    headerBg: headerBg ?? this.headerBg,
  );
}
