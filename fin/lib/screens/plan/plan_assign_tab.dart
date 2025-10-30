import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../services/reference_api_service.dart';
import '../../core/models/reference_item.dart';
import '../../core/models/account.dart';

class PlanAssignTab extends StatefulWidget {
  const PlanAssignTab({super.key});

  @override
  State<PlanAssignTab> createState() => _PlanAssignTabState();
}

class _PlanAssignTabState extends State<PlanAssignTab> {
  final ApiService apiService = ApiService("http://localhost:3000");
  final ReferenceApiService refApiService = ReferenceApiService(
    "http://localhost:3000",
  );

  ReferenceItem? selectedKekv;

  List<Map<String, dynamic>> data = [
    {
      "account": "123456 - 001",
      "kekv": "2111",
      "months": [
        1000,
        1200,
        1500,
        1100,
        1300,
        1250,
        1400,
        1600,
        1700,
        1800,
        1900,
        2000,
      ],
      "total": 17850,
      "currentMonth": 1800,
    },
  ];

  final columns = [
    "Особовий рахунок",
    "КЕКВ",
    "Січень",
    "Лютий",
    "Березень",
    "Квітень",
    "Травень",
    "Червень",
    "Липень",
    "Серпень",
    "Вересень",
    "Жовтень",
    "Листопад",
    "Грудень",
    "Всього",
    "План поточний",
  ];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get filteredData {
    if (_searchQuery.isEmpty) return data;
    return data.where((row) {
      final account = (row["account"] ?? '').toString().toLowerCase();
      final kekv = (row["kekv"] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return account.contains(query) || kekv.contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _addRowDialog() async {
    List<Account> accounts = [];
    Account? selectedAccount;

    try {
      // accounts = await apiService.fetchAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка завантаження акаунтів: $e")),
      );
      return;
    }

    final monthCtrls = List.generate(12, (_) => TextEditingController());
    selectedKekv = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Додати рядок"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Autocomplete<Account>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Account>.empty();
                    }
                    return accounts.where((acc) {
                      final query = textEditingValue.text.toLowerCase();
                      return acc.accountNumber.toLowerCase().contains(query) ||
                          (acc.rozporiadNumber.toLowerCase().contains(query) ??
                              false);
                    });
                  },
                  displayStringForOption: (Account acc) =>
                      "${acc.accountNumber} - ${acc.rozporiadNumber}",
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: "Особовий рахунок",
                          ),
                        );
                      },
                  onSelected: (Account acc) {
                    selectedAccount = acc;
                  },
                ),

                const SizedBox(height: 8),

                Autocomplete<ReferenceItem>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<ReferenceItem>.empty();
                    }
                    try {
                      final response = await refApiService.fetchCategories();
                      final kekvItems = response['КЕКВ'] ?? [];
                      return kekvItems.where(
                        (item) => item.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    } catch (e) {
                      return const Iterable<ReferenceItem>.empty();
                    }
                  },
                  displayStringForOption: (ReferenceItem item) => item.name,
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(labelText: "КЕКВ"),
                        );
                      },
                  onSelected: (ReferenceItem item) {
                    selectedKekv = item;
                  },
                ),

                const SizedBox(height: 8),

                for (int i = 0; i < 12; i++)
                  TextField(
                    controller: monthCtrls[i],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Місяць ${i + 1}"),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Скасувати"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedAccount == null || selectedKekv == null) return;

                final months = monthCtrls
                    .map((c) => int.tryParse(c.text) ?? 0)
                    .toList();
                final total = months.fold(0, (a, b) => a + b);

                setState(() {
                  data.add({
                    "account":
                        "${selectedAccount!.accountNumber} - ${selectedAccount!.rozporiadNumber}",
                    "kekv": selectedKekv!.name,
                    "months": months,
                    "total": total,
                  });
                });

                Navigator.pop(context);
              },
              child: const Text("Додати"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth / columns.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: null,
                label: const Text("Контрольна сума"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addRowDialog,
                icon: const Icon(Icons.add),
                label: const Text("Додати пропозиції до плану та кошторису"),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Пошук за рахунком або КЕКВ',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: screenWidth,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Row(
                      children: columns
                          .map(
                            (col) => Container(
                              width: columnWidth,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.blue[100],
                              ),
                              child: Text(
                                col,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    ...filteredData.map((row) {
                      final months = row["months"] as List<dynamic>;
                      final rowValues = [
                        row["account"],
                        row["kekv"],
                        ...months,
                        row["total"],
                        row["currentMonth"] ?? 0,
                      ];
                      return Row(
                        children: rowValues
                            .map(
                              (cell) => Container(
                                width: columnWidth,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text(
                                  cell.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
