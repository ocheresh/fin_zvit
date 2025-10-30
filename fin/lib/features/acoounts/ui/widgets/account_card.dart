import 'package:flutter/material.dart';
import '../../../../core/models/account.dart';
import 'actions_menu.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.scale,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fs = 14.0 * scale;
    final fsHead = 15.0 * scale;
    final pad = (12.0 * scale).clamp(8.0, 16.0);

    return Card(
      margin: EdgeInsets.only(bottom: pad),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.accountNumber} — ${account.legalName}',
                      style: TextStyle(
                        fontSize: fsHead,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: pad / 2),
                    Text(
                      '№ розп.: ${account.rozporiadNumber}',
                      style: TextStyle(fontSize: fs),
                    ),
                    Text(
                      'ЄДРПОУ: ${account.edrpou}',
                      style: TextStyle(fontSize: fs),
                    ),
                    Text(
                      'Підпорядкованість: ${account.subordination ?? '-'}',
                      style: TextStyle(fontSize: fs),
                    ),
                    Text(
                      'Дод. інфо: ${account.additionalInfo.isEmpty ? '-' : account.additionalInfo}',
                      style: TextStyle(fontSize: fs),
                    ),
                  ],
                ),
              ),
              // трикрапка
              RowActionsMenu(
                onEdit: onEdit,
                onDelete: onDelete,
                iconSize: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
