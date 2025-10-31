import 'package:flutter/material.dart';
import 'view_helpers.dart';
import 'searchable_dropdown.dart';

const double _wideBp = 920;

class FilterBar extends StatelessWidget {
  final List<String> kpkvOptions;
  final List<String> fundOptions;
  final List<int> monthOptions;
  final List<int> seqOptions;

  final String? kpkvId;
  final String? fundId;
  final int? month;
  final int? seqNo;

  final String Function(String id) kpkvLabelOf;
  final String Function(String id) fundLabelOf;

  final void Function(String? kpkvId, String? fundId, int? month, int? seqNo)
  onChanged;
  final VoidCallback onClear;

  const FilterBar({
    super.key,
    required this.kpkvOptions,
    required this.fundOptions,
    required this.monthOptions,
    required this.seqOptions,
    required this.kpkvId,
    required this.fundId,
    required this.month,
    required this.seqNo,
    required this.kpkvLabelOf,
    required this.fundLabelOf,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // items із «Усі» + варіанти (пошук працює по тексту child)
    final kpkvItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Усі')),
      ...kpkvOptions.map(
        (id) =>
            DropdownMenuItem<String?>(value: id, child: Text(kpkvLabelOf(id))),
      ),
    ];
    final fundItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Усі')),
      ...fundOptions.map(
        (id) =>
            DropdownMenuItem<String?>(value: id, child: Text(fundLabelOf(id))),
      ),
    ];
    final monthItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('Усі')),
      ...monthOptions.map(
        (m) => DropdownMenuItem<int?>(value: m, child: Text(monthsFull[m - 1])),
      ),
    ];
    final seqItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('Усі')),
      ...seqOptions.map(
        (n) => DropdownMenuItem<int?>(value: n, child: Text('$n')),
      ),
    ];

    final kpkvDd = Expanded(
      child: SearchableDropdown<String?>(
        label: 'КПКВ',
        searchHint: 'Пошук КПКВ…',
        value: kpkvId,
        items: kpkvItems,
        onChanged: (v) => onChanged(v, fundId, month, seqNo),
      ),
    );

    final fundDd = Expanded(
      child: SearchableDropdown<String?>(
        label: 'Фонд',
        searchHint: 'Пошук фонду…',
        value: fundId,
        items: fundItems,
        onChanged: (v) => onChanged(kpkvId, v, month, seqNo),
      ),
    );

    final monthDd = SizedBox(
      width: 220,
      child: SearchableDropdown<int?>(
        label: 'Місяць',
        searchHint: 'Введіть назву/номер…',
        value: month,
        items: monthItems,
        onChanged: (v) => onChanged(kpkvId, fundId, v, seqNo),
      ),
    );

    final seqDd = SizedBox(
      width: 200,
      child: SearchableDropdown<int?>(
        label: '№ пропозиції',
        searchHint: 'Введіть номер…',
        value: seqNo,
        items: seqItems,
        onChanged: (v) => onChanged(kpkvId, fundId, month, v),
      ),
    );

    final clearBtn = SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onClear,
        icon: const Icon(Icons.refresh),
        label: const Text('Скинути'),
      ),
    );

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= _wideBp;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  kpkvDd,
                  const SizedBox(width: 12),
                  fundDd,
                  const SizedBox(width: 12),
                  monthDd,
                  const SizedBox(width: 12),
                  seqDd,
                  const SizedBox(width: 12),
                  clearBtn,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: kpkvDd),
                    const SizedBox(width: 12),
                    Expanded(child: fundDd),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: monthDd),
                    const SizedBox(width: 12),
                    Expanded(child: seqDd),
                  ],
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: clearBtn),
              ],
            );
          },
        ),
      ),
    );
  }
}
