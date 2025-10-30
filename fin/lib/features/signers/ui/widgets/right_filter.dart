import 'package:flutter/material.dart';

class RightFilter extends StatelessWidget {
  final String? value; // null | 'first' | 'second'
  final ValueChanged<String?> onChanged;
  const RightFilter({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Усі'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        FilterChip(
          label: const Text('Перше'),
          selected: value == 'first',
          onSelected: (_) => onChanged('first'),
        ),
        FilterChip(
          label: const Text('Друге'),
          selected: value == 'second',
          onSelected: (_) => onChanged('second'),
        ),
      ],
    );
  }
}
