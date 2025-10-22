import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  final List<bool> current;
  const MonthPickerDialog({required this.current});

  @override
  State<MonthPickerDialog> createState() => MonthPickerDialogState();
}

class MonthPickerDialogState extends State<MonthPickerDialog> {
  late List<bool> sel;

  @override
  void initState() {
    super.initState();
    sel = List<bool>.from(widget.current);
  }

  @override
  Widget build(BuildContext context) {
    final fs = 14.0;
    return AlertDialog(
      title: const Text('Вибір місяців'),
      content: SizedBox(
        width: 420,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(12, (i) {
            final label = '${i + 1}';
            final on = sel[i];
            return FilterChip(
              selected: on,
              label: Text(label, style: TextStyle(fontSize: fs)),
              onSelected: (v) => setState(() => sel[i] = v),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати'),
        ),
        TextButton(
          onPressed: () {
            // гарантуємо, що хоч один місяць увімкнено
            if (!sel.contains(true)) {
              final m = DateTime.now().month;
              sel[m - 1] = true;
            }
            Navigator.pop(context, sel);
          },
          child: const Text('Застосувати'),
        ),
      ],
    );
  }
}
