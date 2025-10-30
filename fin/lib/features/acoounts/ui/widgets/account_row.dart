import 'package:flutter/material.dart';
import '../../../../core/models/account.dart';
import 'breakpoints.dart';
import 'actions_menu.dart';

class AccountRow extends StatelessWidget {
  final Account account;
  final double scale;
  final Breakpoints bp;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountRow({
    super.key,
    required this.account,
    required this.scale,
    required this.bp,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fs = 14.0 * scale;
    final rowH = (48.0 * scale).clamp(42.0, 56.0);
    final pad = (12.0 * scale).clamp(8.0, 16.0);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: rowH,
        padding: EdgeInsets.symmetric(horizontal: pad * .75),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Row(
          children: [
            _Cell(account.accountNumber, fs, flex: 14),
            if (!bp.isMedium) _Cell(account.rozporiadNumber, fs, flex: 12),
            _Cell(account.legalName, fs, flex: 20),
            if (!bp.isMedium) _Cell(account.edrpou, fs, flex: 10),
            _Cell(account.subordination ?? '-', fs, flex: 18),
            if (bp.isLarge)
              _Cell(
                account.additionalInfo.isEmpty ? '-' : account.additionalInfo,
                fs,
                flex: 20,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Дії: тільки трикрапка
            Expanded(
              flex: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: RowActionsMenu(
                  onEdit: onEdit,
                  onDelete: onDelete,
                  iconSize: 22 * scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final double fs;
  final int flex;
  final int? maxLines;
  final TextOverflow? overflow;
  const _Cell(
    this.text,
    this.fs, {
    this.flex = 10,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: maxLines,
          overflow: overflow,
          style: TextStyle(fontSize: fs),
        ),
      ),
    );
  }
}
