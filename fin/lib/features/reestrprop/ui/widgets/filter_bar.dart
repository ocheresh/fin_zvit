import 'package:flutter/material.dart';
import '../view_helpers.dart';

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

  // 🔎 нове: пошук
  final String searchText;
  final ValueChanged<String> onSearchChanged;

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
    required this.searchText,
    required this.onSearchChanged,
    required this.kpkvLabelOf,
    required this.fundLabelOf,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final kpkv = Expanded(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: kpkvId,
        decoration: const InputDecoration(labelText: 'КПКВ'),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('Усі')),
          ...kpkvOptions.map(
            (id) => DropdownMenuItem(value: id, child: Text(kpkvLabelOf(id))),
          ),
        ],
        onChanged: (v) => onChanged(v, fundId, month, seqNo),
      ),
    );

    final fund = Expanded(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: fundId,
        decoration: const InputDecoration(labelText: 'Фонд'),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('Усі')),
          ...fundOptions.map(
            (id) => DropdownMenuItem(value: id, child: Text(fundLabelOf(id))),
          ),
        ],
        onChanged: (v) => onChanged(kpkvId, v, month, seqNo),
      ),
    );

    final monthDd = SizedBox(
      width: 220,
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: month,
        decoration: const InputDecoration(labelText: 'Місяць'),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('Усі')),
          ...monthOptions.map(
            (m) => DropdownMenuItem(value: m, child: Text(monthsFull[m - 1])),
          ),
        ],
        onChanged: (v) => onChanged(kpkvId, fundId, v, seqNo),
      ),
    );

    final seq = SizedBox(
      width: 200,
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: seqNo,
        decoration: const InputDecoration(labelText: '№ пропозиції'),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('Усі')),
          ...seqOptions.map(
            (n) => DropdownMenuItem(value: n, child: Text('$n')),
          ),
        ],
        onChanged: (v) => onChanged(kpkvId, fundId, month, v),
      ),
    );

    // 🔎 Поле пошуку
    final search = Expanded(
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Пошук',
          hintText: '№, КПКВ, Фонд, місяць, підписант…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchText.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onSearchChanged(''),
                ),
        ),
        onChanged: onSearchChanged,
        controller: TextEditingController(text: searchText)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: searchText.length),
          ),
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
                  search,
                  const SizedBox(width: 12),
                  kpkv,
                  const SizedBox(width: 12),
                  fund,
                  const SizedBox(width: 12),
                  monthDd,
                  const SizedBox(width: 12),
                  seq,
                  const SizedBox(width: 12),
                  clearBtn,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: kpkv),
                    const SizedBox(width: 12),
                    Expanded(child: fund),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: monthDd),
                    const SizedBox(width: 12),
                    Expanded(child: seq),
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
