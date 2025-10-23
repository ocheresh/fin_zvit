// lib/rozrah_prop/widgets/table_cells.dart
import 'package:flutter/material.dart';

class FlexCols {
  static const osob = 2;
  static const name = 4;
  static const kekv = 2;
  static const vytr = 3;
  static const unit = 2;
  static const qty = 2;
  static const price = 2;
  static const sum = 2;
  static const prop = 2;
  static const actions = 2;
}

const double kCellHeight = 36;
const double kCellHPad = 8;

Widget cellText(
  String s, {
  TextAlign align = TextAlign.left,
  FontWeight? weight,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: align == TextAlign.right
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Text(
      s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: weight != null ? TextStyle(fontWeight: weight) : null,
    ),
  );
}

/// універсальний контейнер клітинки з рамкою і фоном для заголовків
class CellBox extends StatelessWidget {
  final Widget child;
  final bool header;
  final Alignment alignment;
  final Color? borderColor;
  final Color? headerBg;

  const CellBox({
    super.key,
    required this.child,
    this.header = false,
    this.alignment = Alignment.centerLeft,
    this.borderColor,
    this.headerBg,
  });

  @override
  Widget build(BuildContext context) {
    final bColor =
        borderColor ?? Theme.of(context).dividerColor.withOpacity(0.7);
    final bg = header ? (headerBg ?? const Color(0xFFDDEAFF)) : null;

    return Container(
      height: kCellHeight,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: kCellHPad),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bColor, width: 1),
      ),
      child: child,
    );
  }
}
