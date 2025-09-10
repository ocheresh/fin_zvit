import 'package:flutter/material.dart';
import '../../services/reference_api_service.dart';
import '../../models/reference_item.dart';
import 'prop_budget_tabs_screen.dart';

class PropSelectionScreen extends StatefulWidget {
  const PropSelectionScreen({super.key});

  @override
  State<PropSelectionScreen> createState() => _PropSelectionScreenState();
}

class _PropSelectionScreenState extends State<PropSelectionScreen> {
  final ReferenceApiService apiService = ReferenceApiService(
    "http://localhost:3000",
  );

  int selectedYear = DateTime.now().year;
  ReferenceItem? selectedKpkv;
  ReferenceItem? selectedFund;

  List<ReferenceItem> kpkvList = [];
  List<ReferenceItem> fundList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    setState(() => _loading = true);
    try {
      final categories = await apiService.fetchCategories();
      setState(() {
        kpkvList = categories['КПКВ'] ?? [];
        fundList = categories['Фонд'] ?? [];

        // Автоматично обираємо перші елементи
        selectedKpkv = kpkvList.isNotEmpty ? kpkvList.first : null;
        selectedFund = fundList.isNotEmpty ? fundList.first : null;

        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вибір параметрів'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Рік
            Text('Рік', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<int>(
              value: selectedYear,
              isExpanded: true,
              items: List.generate(10, (index) {
                final year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedYear = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // КПКВ
            Text('КПКВ', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<ReferenceItem>(
              value: selectedKpkv,
              isExpanded: true,
              hint: const Text('Оберіть КПКВ'),
              items: kpkvList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item.name));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedKpkv = value);
              },
            ),
            const SizedBox(height: 16),

            // Фонд
            Text('Фонд', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<ReferenceItem>(
              value: selectedFund,
              isExpanded: true,
              hint: const Text('Оберіть Фонд'),
              items: fundList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item.name));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedFund = value);
              },
            ),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: selectedKpkv != null && selectedFund != null
                    ? () {
                        // Дія після вибору
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropBudgetTabsScreen(
                              year: selectedYear,
                              kpkv: selectedKpkv!,
                              fund: selectedFund!,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Підтвердити'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
