import 'package:flutter/material.dart';
import 'package:fin/core/models/reference_item.dart';

const List<String> monthsShort = [
  'Січ',
  'Лют',
  'Бер',
  'Квіт',
  'Трав',
  'Чер',
  'Лип',
  'Серп',
  'Вер',
  'Жовт',
  'Лист',
  'Груд',
];

const List<String> monthsFull = [
  'Січень',
  'Лютий',
  'Березень',
  'Квітень',
  'Травень',
  'Червень',
  'Липень',
  'Серпень',
  'Вересень',
  'Жовтень',
  'Листопад',
  'Грудень',
];

Map<String, String> toIdNameMap(List<ReferenceItem>? list) {
  if (list == null) return const {};
  final m = <String, String>{};
  for (final e in list) {
    final id = '${e.id}'.trim();
    if (id.isEmpty) continue;
    final name = (e.name ?? '').trim();
    if (name.isEmpty) continue;
    m[id] = name;
  }
  return m;
}

String refName(Map<String, String> map, String id) =>
    id.isEmpty ? '' : (map[id] ?? id);

String fmtDate(DateTime? d, {bool dashIfNull = false}) {
  if (d == null) return dashIfNull ? '—' : '';
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

Widget fitText(String s) {
  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 60, maxWidth: 180),
    child: FittedBox(
      alignment: Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Text(s, overflow: TextOverflow.ellipsis),
    ),
  );
}

Widget kv(String k, String v) {
  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 120, maxWidth: 420),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(
            text: '$k: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: v),
        ],
      ),
    ),
  );
}

String nameOrId(Map<String, String> map, String id) =>
    id.isEmpty ? '' : (map[id] ?? id);
