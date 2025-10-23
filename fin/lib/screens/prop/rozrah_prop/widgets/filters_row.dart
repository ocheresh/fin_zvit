import 'package:flutter/material.dart';

typedef OnFilterChanged = void Function(String key, String value);

class FiltersRow extends StatelessWidget {
  final Map<String, String> current;
  final OnFilterChanged onChanged;
  final VoidCallback onClearAll;
  final List<String> Function(String key) optionsFor;

  const FiltersRow({
    super.key,
    required this.current,
    required this.onChanged,
    required this.onClearAll,
    required this.optionsFor,
  });

  InputDecoration _dec(BuildContext context, String hint, String key) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      suffixIcon: current[key]!.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              padding: EdgeInsets.zero,
              splashRadius: 14,
              onPressed: () => onChanged(key, ''),
            )
          : null,
    );
  }

  /// Універсальне поле автодоповнення для одного ключа фільтра.
  Widget _autoField(
    BuildContext context, {
    required String key,
    required String hint,
  }) {
    final opts = optionsFor(key);

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue tev) {
        final q = tev.text.trim().toLowerCase();
        if (q.isEmpty) return opts;
        return opts.where((o) => o.toLowerCase().contains(q));
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        // Синхронізуємо контролер з поточним значенням
        final cur = current[key] ?? '';
        if (textController.text != cur) {
          // не викликає перерисовки, лише оновлює вміст інпуту
          textController.text = cur;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
        }
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: _dec(context, hint, key),
          onChanged: (v) => onChanged(key, v), // ввод одразу застосовує фільтр
          onSubmitted: (v) => onChanged(key, v),
        );
      },
      onSelected: (val) => onChanged(key, val), // вибір із підказок
      optionsViewBuilder: (context, onSelected, iterable) {
        final items = iterable.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, minWidth: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final v = items[i];
                  return InkWell(
                    onTap: () => onSelected(v),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        v,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Один рядок: 5 полів (із автодоповненням) + «Скинути»
    return Row(
      children: [
        Expanded(
          child: _autoField(
            context,
            key: 'osobovyiRahunok',
            hint: 'особовий рахунок',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _autoField(
            context,
            key: 'naimenuvannia',
            hint: 'найменування',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _autoField(context, key: 'kodVydatkiv', hint: 'код видатків'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _autoField(context, key: 'naimenVytrat', hint: 'витрати'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _autoField(
            context,
            key: 'nomerPropozytsii',
            hint: '№ пропозиції',
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 140),
          child: SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.filter_alt_off, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Скинути фільтри'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
