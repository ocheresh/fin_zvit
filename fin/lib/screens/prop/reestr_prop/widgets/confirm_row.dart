import 'package:flutter/material.dart';

class ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const ConfirmRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final styleLabel = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final styleValue = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text(label, style: styleLabel)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: styleValue,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
