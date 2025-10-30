import 'package:flutter/material.dart';

class RowActionsMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double iconSize;
  const RowActionsMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Дії',
      icon: Icon(Icons.more_horiz, size: iconSize),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Редагувати'),
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 0,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Видалити'),
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 0,
          ),
        ),
      ],
    );
  }
}
