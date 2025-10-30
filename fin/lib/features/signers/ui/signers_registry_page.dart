import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/core/models/signer.dart';
import '../mvi/signer_viewmodel.dart';
import '../mvi/signer_intent.dart';
import 'utils/signers_utils.dart';
import 'widgets/right_filter.dart';
import 'widgets/signers_table.dart';
import 'widgets/signers_cards.dart';
import 'widgets/signer_dialog.dart';

class SignersRegistryPage extends StatefulWidget {
  const SignersRegistryPage({super.key});
  @override
  State<SignersRegistryPage> createState() => _SignersRegistryPageState();
}

class _SignersRegistryPageState extends State<SignersRegistryPage> {
  String _query = '';
  String? _rightFilter; // null | 'first' | 'second'

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<SignerViewModel>().dispatch(const LoadAll()),
    );
  }

  List<Signer> _applyFilters(List<Signer> src) {
    final q = _query.trim().toLowerCase();
    Iterable<Signer> it = src;
    if (_rightFilter != null) it = it.where((s) => s.signRight == _rightFilter);
    if (q.isNotEmpty) {
      it = it.where(
        (s) =>
            s.position.toLowerCase().contains(q) ||
            s.rank.toLowerCase().contains(q) ||
            s.lastName.toLowerCase().contains(q) ||
            s.firstName.toLowerCase().contains(q) ||
            s.fatherName.toLowerCase().contains(q),
      );
    }
    final items = it.toList()
      ..sort((a, b) {
        int r(String s) => s == 'first' ? 0 : 1;
        final byRight = r(a.signRight).compareTo(r(b.signRight));
        if (byRight != 0) return byRight;
        final byPos = a.position.toLowerCase().compareTo(
          b.position.toLowerCase(),
        );
        if (byPos != 0) return byPos;
        return a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
      });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignerViewModel>();
    final st = vm.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Реєстр підписантів')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<Signer>(
            context: context,
            builder: (ctx) => const SignerDialog(),
          );
          if (created != null) {
            await vm.dispatch(CreateSigner(created));
            if (mounted) _snack('Підписанта додано');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Додати'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Пошук за посадою, званням або ПІБ',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 8),
                RightFilter(
                  value: _rightFilter,
                  onChanged: (v) => setState(() => _rightFilter = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Builder(
              builder: (_) {
                if (st.loading)
                  return const Center(child: CircularProgressIndicator());
                if (st.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Помилка: ${st.error}'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => vm.dispatch(const LoadAll()),
                          child: const Text('Повторити'),
                        ),
                      ],
                    ),
                  );
                }
                final items = _applyFilters(st.items);
                return LayoutBuilder(
                  builder: (context, c) => c.maxWidth >= 960
                      ? SignersTable(items: items)
                      : SignersCards(items: items),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
