import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String searchHint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isExpanded;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.searchHint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: widget.isExpanded,
      value: widget.value,
      decoration: InputDecoration(labelText: widget.label),
      items: widget.items,
      onChanged: widget.onChanged,
      dropdownStyleData: const DropdownStyleData(maxHeight: 360),
      menuItemStyleData: const MenuItemStyleData(),
      // 🔎 головне — пошук усередині
      dropdownSearchData: DropdownSearchData(
        searchController: _searchCtrl,
        searchInnerWidgetHeight: 56,
        searchInnerWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // як фільтрувати (працює по child Text у items)
        searchMatchFn: (item, searchValue) {
          final text = (item.value == null)
              ? 'усі'
              : (item.child is Text
                    ? (item.child as Text).data ?? ''
                    : item.child.toString());
          return text.toLowerCase().contains(searchValue.toLowerCase());
        },
      ),
    );
  }
}
