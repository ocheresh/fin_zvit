import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/reestrprop.dart';
import '../../../../core/models/signer.dart';
import '../../../signers/mvi/signer_viewmodel.dart';
import 'view_helpers.dart';

const double _wideBp = 920;

class ResponsivePropList extends StatelessWidget {
  final List<ReestrProp> items;
  final Map<String, String> kpkvMap;
  final Map<String, String> fundMap;
  final void Function(BuildContext, ReestrProp) openEdit;
  final Future<void> Function(BuildContext, int) onDelete;

  const ResponsivePropList({
    super.key,
    required this.items,
    required this.kpkvMap,
    required this.fundMap,
    required this.openEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final signers =
        context.watch<SignerViewModel>().state.items ?? const <Signer>[];
    final firstMap = {
      for (final s in signers.where((s) => s.signRight == 'first'))
        '${s.id}': (s.lastName ?? '').trim(),
    };
    final secondMap = {
      for (final s in signers.where((s) => s.signRight == 'second'))
        '${s.id}': (s.lastName ?? '').trim(),
    };

    String sig(Map<String, String> m, String id) =>
        (m[id]?.isNotEmpty ?? false) ? m[id]! : (id.isEmpty ? '' : id);

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= _wideBp) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: DataTable(
                columnSpacing: 12,
                headingTextStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                dataTextStyle: Theme.of(context).textTheme.bodyMedium,
                columns: const [
                  DataColumn(label: Text('№')),
                  DataColumn(label: Text('КПКВ')),
                  DataColumn(label: Text('Фонд')),
                  DataColumn(label: Text('Місяць')),
                  DataColumn(label: Text('1-й підпис')),
                  DataColumn(label: Text('2-й підпис')),
                  DataColumn(label: Text('Відпр. ДФ')),
                  DataColumn(label: Text('Прийн. ДФ')),
                  DataColumn(label: Text('Дії')),
                ],
                rows: items.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(fitText('${p.seqNo}')),
                      DataCell(fitText(nameOrId(kpkvMap, p.kpkvId))),
                      DataCell(fitText(nameOrId(fundMap, p.fundId))),
                      DataCell(
                        fitText(monthsShort[(p.month - 1).clamp(0, 11)]),
                      ),
                      DataCell(fitText(sig(firstMap, p.signFirstId))),
                      DataCell(fitText(sig(secondMap, p.signSecondId))),
                      DataCell(fitText(fmtDate(p.sentDfDate))),
                      DataCell(fitText(fmtDate(p.acceptedDfDate))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => openEdit(context, p),
                              tooltip: 'Редагувати',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => onDelete(context, p.id),
                              tooltip: 'Видалити',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = items[i];
            return Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        kv('№', '${p.seqNo}'),
                        kv('Місяць', monthsShort[(p.month - 1).clamp(0, 11)]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        kv('КПКВ', nameOrId(kpkvMap, p.kpkvId)),
                        kv('Фонд', nameOrId(fundMap, p.fundId)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        kv('1-й підпис', sig(firstMap, p.signFirstId)),
                        kv('2-й підпис', sig(secondMap, p.signSecondId)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        kv(
                          'Відпр. ДФ',
                          fmtDate(p.sentDfDate, dashIfNull: true),
                        ),
                        kv(
                          'Прийн. ДФ',
                          fmtDate(p.acceptedDfDate, dashIfNull: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => openEdit(context, p),
                          tooltip: 'Редагувати',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDelete(context, p.id),
                          tooltip: 'Видалити',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
