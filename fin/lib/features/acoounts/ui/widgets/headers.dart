import 'package:flutter/material.dart';
import 'breakpoints.dart';

class TableHeaders extends StatelessWidget {
  final double scale;
  final Breakpoints bp;
  const TableHeaders({super.key, required this.scale, required this.bp});

  @override
  Widget build(BuildContext context) {
    final fsHead = 15.0 * scale;
    final rowH = (48.0 * scale).clamp(42.0, 56.0);
    final pad = (12.0 * scale).clamp(8.0, 16.0);

    return Container(
      height: rowH,
      padding: EdgeInsets.symmetric(horizontal: pad * .75),
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(.6),
      child: Row(
        children: [
          _HCell('Особовий рахунок', fsHead, flex: 14),
          if (!bp.isMedium) _HCell('№ розп-ка коштів', fsHead, flex: 12),
          _HCell('Найменування', fsHead, flex: 20),
          if (!bp.isMedium) _HCell('ЄДРПОУ', fsHead, flex: 10),
          _HCell('Підпорядкованість', fsHead, flex: 18),
          if (bp.isLarge) _HCell('Дод.інфо', fsHead, flex: 20),
          _HCell('Дії', fsHead, flex: 12, alignEnd: true),
        ],
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  final String text;
  final double fs;
  final int flex;
  final bool alignEnd;
  const _HCell(this.text, this.fs, {this.flex = 10, this.alignEnd = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: fs, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
