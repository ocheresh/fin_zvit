import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/core/models/signer.dart';
import '../../mvi/signer_viewmodel.dart';
import '../../mvi/signer_intent.dart';
import '../utils/signers_utils.dart';
import 'signer_dialog.dart';

class SignersCards extends StatelessWidget {
  final List<Signer> items;
  const SignersCards({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Signer>>{};
    for (final s in items) {
      final k = (s.lastName.isNotEmpty ? s.lastName[0].toUpperCase() : '#');
      groups.putIfAbsent(k, () => []).add(s);
    }
    final keys = groups.keys.toList()..sort();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, gi) {
        final key = keys[gi];
        final list = groups[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(key, style: Theme.of(context).textTheme.titleSmall),
            ),
            ...list.map(
              (s) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(s.position),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Звання: ${s.rank}'),
                      Text('Право: ${rightLabel(s.signRight)}'),
                      Text('ПІБ: ${s.lastName} ${s.firstName} ${s.fatherName}'),
                    ],
                  ),
                  trailing: _Actions(s: s),
                ),
              ),
            ),
          ],
        );
      },
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
