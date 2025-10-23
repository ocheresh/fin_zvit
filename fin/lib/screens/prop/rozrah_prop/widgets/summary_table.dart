import 'package:flutter/material.dart';

class SummaryBar extends StatelessWidget {
  final double totalVsogo;
  final int count;

  const SummaryBar({super.key, required this.totalVsogo, required this.count});

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue, // 👈 синій колір рамки
          width: 1, // товщина лінії
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Позицій: $count', overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Text(
              'Всього: ${_fmt(totalVsogo)}',
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
