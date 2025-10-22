import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/format.dart';

Widget calcButtonCell({
  required double scale,
  required double fs,
  required double padH,
  required num calcSum,
  required num totalSum,
}) {
  final Color bg = calcSum == totalSum
      ? Colors.green.withOpacity(.18)
      : (calcSum < totalSum
            ? Colors.lightBlueAccent.withOpacity(.18)
            : Colors.redAccent.withOpacity(.18));

  final double btnH = (36.0 * scale).clamp(30.0, 44.0).toDouble();
  final String sumText = thousands(calcSum);

  return Expanded(
    flex: kFlexMap['Розрахунки'] ?? 12,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: padH),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: btnH),
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              // horizontal: padH * 0.9,
              vertical: 6 * scale,
            ),
            // minimumSize: Size(0, btnH),
            // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: bg,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Column(
            children: [
              Text(
                sumText,
                maxLines: 1,
                style: TextStyle(fontSize: fs, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
