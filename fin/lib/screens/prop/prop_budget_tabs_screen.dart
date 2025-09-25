import 'package:flutter/material.dart';
import '../../models/reference_item.dart';
import 'package:fin/screens/prop/prop_plan_assign_tab.dart';
import 'res_prop_plan_assign_tab.dart';
import '../../services/reference_api_service.dart';

class PropBudgetTabsScreen extends StatefulWidget {
  final int year;
  final ReferenceItem kpkv;
  final ReferenceItem fund;

  const PropBudgetTabsScreen({
    super.key,
    required this.year,
    required this.kpkv,
    required this.fund,
  });

  @override
  State<PropBudgetTabsScreen> createState() => _PropBudgetTabsScreenState();
}

class _PropBudgetTabsScreenState extends State<PropBudgetTabsScreen>
    with SingleTickerProviderStateMixin {
  final ReferenceApiService apiService = ReferenceApiService(
    "http://localhost:3000",
  );

  late TabController _tabController;

  late int _selectedYear;
  ReferenceItem? _selectedKpkv;
  ReferenceItem? _selectedFund;

  List<ReferenceItem> kpkvList = [];
  List<ReferenceItem> fundList = [];
  bool _loading = true;
  Future<void> _loadReferences() async {
    setState(() => _loading = true);
    try {
      final categories = await apiService.fetchCategories();
      if (!mounted) return; // захист

      setState(() {
        kpkvList = categories['КПКВ'] ?? [];
        fundList = categories['Фонд'] ?? [];

        _selectedKpkv = kpkvList.isNotEmpty ? kpkvList.first : null;
        _selectedFund = fundList.isNotEmpty ? fundList.first : null;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return; // захист

      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _selectedYear = widget.year;

    // спочатку ставимо вхідні значення
    _selectedKpkv = widget.kpkv;
    _selectedFund = widget.fund;

    // а потім підтягуємо дані з API
    _loadReferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Dropdown для року
            DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: Colors.blueGrey[900],
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: List.generate(10, (index) {
                final year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (val) {
                setState(() => _selectedYear = val!);
              },
            ),

            const SizedBox(width: 8),

            // Dropdown для КПКВ
            DropdownButton<ReferenceItem>(
              value: _selectedKpkv,
              dropdownColor: Colors.blueGrey[900],
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: kpkvList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item.name));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedKpkv = val);
              },
            ),

            const SizedBox(width: 8),

            // Dropdown для Фонду
            DropdownButton<ReferenceItem>(
              value: _selectedFund,
              dropdownColor: Colors.blueGrey[900],
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: fundList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item.name));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedFund = val);
              },
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.5,
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Пропозиції змін до кошторису'),
            Tab(text: 'Пропозиції'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PropPlanAssignTab(
            year: _selectedYear,
            kpkv: _selectedKpkv!,
            fund: _selectedFund!,
            onPropozCompleted: () {
              _tabController.animateTo(1);
            },
          ),
          ResPropPlanPage(
            year: _selectedYear,
            kpkv: _selectedKpkv!.name,
            fund: _selectedFund!.name,
          ),
        ],
      ),
    );
  }
}
