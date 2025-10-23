// lib/rozrah_prop/widgets/proposal_row.dart
import 'package:flutter/material.dart';
import '../models/proposal_calc_item.dart';
import 'table_cells.dart';

class ProposalDataRow extends StatelessWidget {
  final ProposalCalcItem item;
  const ProposalDataRow({super.key, required this.item});

  String _n(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: FlexCols.osob,
          child: CellBox(child: cellText(item.osobovyiRahunok)),
        ),
        Expanded(
          flex: FlexCols.name,
          child: CellBox(child: cellText(item.naimenuvannia)),
        ),
        Expanded(
          flex: FlexCols.kekv,
          child: CellBox(child: cellText(item.kodVydatkiv)),
        ),
        Expanded(
          flex: FlexCols.vytr,
          child: CellBox(child: cellText(item.naimenVytrat)),
        ),
        Expanded(
          flex: FlexCols.unit,
          child: CellBox(child: cellText(item.odVymiru)),
        ),
        Expanded(
          flex: FlexCols.qty,
          child: CellBox(
            child: cellText(_n(item.kilkist), align: TextAlign.right),
          ),
        ),
        Expanded(
          flex: FlexCols.price,
          child: CellBox(
            child: cellText(_n(item.tsinaZaOdynts), align: TextAlign.right),
          ),
        ),
        Expanded(
          flex: FlexCols.sum,
          child: CellBox(
            child: cellText(_n(item.vsogo), align: TextAlign.right),
          ),
        ),
        Expanded(
          flex: FlexCols.prop,
          child: CellBox(child: cellText(item.nomerPropozytsii)),
        ),

        Expanded(
          flex: FlexCols.actions,
          child: CellBox(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashRadius: 18,
                  tooltip: 'Редагувати',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Редагувати: заглушка')),
                    );
                  },
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashRadius: 18,
                  tooltip: 'Видалити',
                  onPressed: () async {
                    final desc =
                        '${item.naimenuvannia} (КЕКВ: ${item.kodVydatkiv})\n'
                        'Кількість: ${_n(item.kilkist)}, Ціна: ${_n(item.tsinaZaOdynts)}\n'
                        'Всього: ${_n(item.vsogo)}, № проп.: ${item.nomerPropozytsii}';

                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Підтвердження видалення'),
                        content: Text('Видалити цей запис?\n\n$desc'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Скасувати'),
                          ),
                          FilledButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Видалити'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Запис видалено (заглушка)'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
