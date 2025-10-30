import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/core/models/signer.dart';
import '../../mvi/signer_viewmodel.dart';
import '../../mvi/signer_intent.dart';
import '../utils/signers_utils.dart';
import 'signer_dialog.dart';

class SignersTable extends StatelessWidget {
  final List<Signer> items;
  const SignersTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const hPad = 12.0;
    Widget headerCell(String t, {int flex = 1}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
        child: Text(t, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
    Widget rowCell(String t, {int flex = 1}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
        child: Text(t, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                headerCell('Посада', flex: 2),
                headerCell('Звання'),
                headerCell('Право'),
                headerCell('Прізвище'),
                headerCell('Імʼя'),
                headerCell('По-батькові'),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = items[i];
              return Row(
                children: [
                  rowCell(s.position, flex: 2),
                  rowCell(s.rank),
                  rowCell(rightLabel(s.signRight)),
                  rowCell(s.lastName),
                  rowCell(s.firstName),
                  rowCell(s.fatherName),
                  _Actions(s: s),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final Signer s;
  const _Actions({required this.s});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SignerViewModel>();
    return PopupMenuButton<String>(
      tooltip: 'Дії',
      onSelected: (v) async {
        if (v == 'edit') {
          final updated = await showDialog<Signer>(
            context: context,
            builder: (ctx) => SignerDialog(initial: s),
          );
          if (updated != null) {
            await vm.dispatch(UpdateSigner(updated));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Зміни збережено')));
            }
          }
        }
        if (v == 'delete') {
          final ok = await _confirmDelete(context, s);
          if (ok == true) {
            await vm.dispatch(DeleteSigner(s.id));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Підписанта видалено')),
              );
            }
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Редагувати')),
        PopupMenuItem(value: 'delete', child: Text('Видалити')),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

Future<bool?> _confirmDelete(BuildContext context, Signer s) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Підтвердження'),
      content: Text('Видалити: ${s.lastName} ${s.firstName} ${s.fatherName}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Видалити'),
        ),
      ],
    ),
  );
}
