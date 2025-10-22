import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/format.dart';

Widget calcButtonCell({
  required double scale,
  required double fs,
  required double padH,
  required num calcSum,
  required num totalSum,
  VoidCallback? onOpen,
}) {
  final equal = calcSum == totalSum;
  final less = calcSum < totalSum;
  final more = calcSum > totalSum;

  final bg = equal
      ? Colors.green.withOpacity(.12)
      : (less
            ? Colors.lightBlue.withOpacity(.12)
            : Colors.red.withOpacity(.12));

  return Expanded(
    flex: kFlexMap['Розрахунки'] ?? 10,
    child: Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Container(
        color: bg,
        alignment: Alignment.center,
        child: TextButton(
          onPressed: onOpen,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: padH,
              vertical: 8 * scale,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            thousands(calcSum),
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    ),
  );
}
