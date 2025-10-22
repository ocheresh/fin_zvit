import 'package:flutter/material.dart';
import '../utils/constants.dart';

typedef OnFilterChanged = void Function(String column, String value);

class FilterRow extends StatelessWidget {
  final double scale;
  final double padH;
  final double fs;
  final Map<String, String> current;
  final OnFilterChanged onChanged;

  const FilterRow({
    super.key,
    required this.scale,
    required this.padH,
    required this.fs,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintStyle = TextStyle(
      fontSize: fs * 0.9,
      color: theme.colorScheme.onSurface.withOpacity(.5),
    );

    InputDecoration deco(String h) => InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: padH,
        vertical: 8 * scale,
      ),
      hintText: _hintFor(h),
      hintStyle: hintStyle,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: .8),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
    );

    Widget field(String h) {
      // ❌ не фільтруємо "Дії" — рендеримо пустий плейсхолдер із тим самим flex
      if (h == 'Дії') {
        return Expanded(flex: kFlexMap[h] ?? 6, child: const SizedBox.shrink());
      }

      return Expanded(
        flex: kFlexMap[h] ?? 6,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH / 2),
          child: TextField(
            controller: TextEditingController(text: current[h] ?? '')
              ..selection = TextSelection.collapsed(
                offset: (current[h] ?? '').length,
              ),
            onChanged: (v) => onChanged(h, v),
            style: TextStyle(fontSize: fs),
            decoration: deco(h),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26, width: 1)),
      ),
      child: Row(children: kFinanceHeaders.map(field).toList()),
    );
  }

  String _hintFor(String h) {
    if (h == 'Всього' ||
        int.tryParse(h) != null ||
        h == 'Номер пропозиції' ||
        h == 'Розрахунки') {
      return 'число: >1000, 100-200…';
    }
    return 'фільтр…';
  }
}
