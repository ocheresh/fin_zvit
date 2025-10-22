import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'fit_text.dart';

Widget highlightedCell(
  String text,
  String keyHeader,
  double fs,
  double padH,
  Color bg, {
  bool alignRight = false,
}) {
  return Expanded(
    flex: kFlexMap[keyHeader] ?? 6,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: padH),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      // 🔹 Якщо клітинка не пуста — фон прозорий, лише заголовки кольорові
      child: Container(
        color: text.trim().isEmpty ? Colors.transparent : Colors.transparent,
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: fitText(
          text,
          fs,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          bold: true,
        ),
      ),
    ),
  );
}
