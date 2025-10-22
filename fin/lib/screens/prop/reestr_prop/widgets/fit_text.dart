import 'package:flutter/material.dart';

Widget fitTextBold(String text, double baseFont, {TextAlign? textAlign}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlign == TextAlign.right
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Text(
      text,
      maxLines: 1,
      softWrap: false,
      textAlign: textAlign,
      style: TextStyle(fontSize: baseFont, fontWeight: FontWeight.w700),
    ),
  );
}

Widget fitText(
  String text,
  double baseFont, {
  TextAlign? textAlign,
  bool bold = true,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: textAlign == TextAlign.right
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Text(
      text,
      maxLines: 1,
      softWrap: false,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: baseFont,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
      ),
    ),
  );
}
