import 'package:flutter/material.dart';

class ActionButtonsCell extends StatelessWidget {
  final int flex;
  final double fs;
  final double iconSize;
  final double padH;
  final Color bg;
  final double rowH;
  final VoidCallback? onEdit; // ⬅️ нове
  final VoidCallback? onDelete; // ⬅️ нове

  const ActionButtonsCell({
    super.key,
    required this.flex,
    required this.fs,
    required this.iconSize,
    required this.padH,
    required this.bg,
    required this.rowH,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Container(
          color: bg,
          alignment: Alignment.centerLeft,
          child: LayoutBuilder(
            builder: (context, cc) {
              final availableW = cc.maxWidth;
              const fullThreshold = 220.0;
              const compactThreshold = 160.0;

              final isFull = availableW >= fullThreshold;
              final isCompact = !isFull && availableW >= compactThreshold;

              final btnStyle = TextButton.styleFrom(
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -3,
                ),
                minimumSize: Size(0, rowH * 0.82),
                padding: EdgeInsets.symmetric(horizontal: padH * 0.8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );

              if (isFull) {
                return Row(
                  children: [
                    TextButton.icon(
                      style: btnStyle,
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined, size: iconSize),
                      label: Text(
                        'Редагувати',
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      style: btnStyle,
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, size: iconSize),
                      label: Text(
                        'Видалити',
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              } else if (isCompact) {
                return Row(
                  children: [
                    TextButton.icon(
                      style: btnStyle,
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined, size: iconSize),
                      label: Text(
                        'Ред.',
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      style: btnStyle,
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, size: iconSize),
                      label: Text(
                        'Видал.',
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      tooltip: 'Редагувати',
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined, size: iconSize),
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                      constraints: BoxConstraints.tight(
                        Size(iconSize + 12, rowH * 0.82),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Видалити',
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, size: iconSize),
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                      constraints: BoxConstraints.tight(
                        Size(iconSize + 12, rowH * 0.82),
                      ),
                    ),
                    const Spacer(),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
