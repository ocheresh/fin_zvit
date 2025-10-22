import 'package:flutter/material.dart';

class ActionButtonsCell extends StatelessWidget {
  final int flex;
  final double fs;
  final double iconSize;
  final double padH;
  final Color bg;
  final double rowH;

  const ActionButtonsCell({
    super.key,
    required this.flex,
    required this.fs,
    required this.iconSize,
    required this.padH,
    required this.bg,
    required this.rowH,
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
                    _ScaledTextButton(
                      icon: Icons.edit_outlined,
                      label: 'Редагувати',
                      iconSize: iconSize,
                      textSize: fs,
                      style: btnStyle,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 6),
                    _ScaledTextButton(
                      icon: Icons.delete_outline,
                      label: 'Видалити',
                      iconSize: iconSize,
                      textSize: fs,
                      style: btnStyle,
                      onPressed: () {},
                    ),
                  ],
                );
              } else if (isCompact) {
                return Row(
                  children: [
                    _ScaledTextButton(
                      icon: Icons.edit_outlined,
                      label: 'Ред.',
                      iconSize: iconSize,
                      textSize: fs,
                      style: btnStyle,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                    _ScaledTextButton(
                      icon: Icons.delete_outline,
                      label: 'Видал.',
                      iconSize: iconSize,
                      textSize: fs,
                      style: btnStyle,
                      onPressed: () {},
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      tooltip: 'Редагувати',
                      onPressed: () {},
                      icon: Icon(Icons.edit_outlined, size: iconSize),
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(
                        Size(iconSize + 12, rowH * 0.82),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Видалити',
                      onPressed: () {},
                      icon: Icon(Icons.delete_outline, size: iconSize),
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                      padding: EdgeInsets.zero,
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

class _ScaledTextButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final double textSize;
  final ButtonStyle style;
  final VoidCallback onPressed;

  const _ScaledTextButton({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.textSize,
    required this.style,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: style,
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      label: SizedBox(
        height: textSize + 6,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
