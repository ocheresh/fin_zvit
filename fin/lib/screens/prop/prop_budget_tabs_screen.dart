import 'package:flutter/material.dart';
import '../../models/reference_item.dart';
import 'package:fin/screens/prop/prop_plan_assign_tab.dart';
import 'res_prop_plan_assign_tab.dart';
import '../../services/reference_api_service.dart';

class PropBudgetTabsScreen extends StatefulWidget {
  const PropBudgetTabsScreen({super.key});

  @override
  State<PropBudgetTabsScreen> createState() => _PropBudgetTabsScreenState();
}

class _PropBudgetTabsScreenState extends State<PropBudgetTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late int _selectedYear;
  late String _selectedKpkv;
  late String _selectedFund;

  final List<String> kpkvList = ["2101020/4", "2101150/6"];
  final List<String> fundList = ["Загальний", "Спеціальний"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _selectedYear = 2025;
    _selectedKpkv = kpkvList.first;
    _selectedFund = fundList.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                children: [
                  TemplateDropdown<int>(
                    items: [2025, 2024, 2023],
                    selectedItem: _selectedYear,
                    itemLabel: (year) => year.toString(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                  const SizedBox(width: 8),
                  TemplateDropdown<String>(
                    items: kpkvList,
                    selectedItem: _selectedKpkv,
                    itemLabel: (year) => year.toString(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedKpkv = val);
                    },
                  ),
                  const SizedBox(width: 8),
                  TemplateDropdown<String>(
                    items: fundList,
                    selectedItem: _selectedFund,
                    itemLabel: (year) => year.toString(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedFund = val);
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          // Текст і колір
          labelColor: Colors.white, // колір активної вкладки
          unselectedLabelColor: Colors.white70, // колір неактивних
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          indicatorColor: Colors.white, // колір індикатора
          indicatorWeight: 3.5,
          tabs: const [
            Tab(text: "Пропозиції змін"),
            Tab(text: "Результати"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // тут замість PropPlanAssignTab використаємо заглушку
          Center(
            child: Text(
              "Рік: $_selectedYear\nКПКВ: $_selectedKpkv\nФонд: $_selectedFund",
              textAlign: TextAlign.center,
            ),
          ),
          // друга вкладка-заглушка
          Center(
            child: Text(
              "Результати для $_selectedKpkv, фонд $_selectedFund",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class TemplateDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel; // як показувати елемент (name)

  const TemplateDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: DropdownButton<T>(
        value: selectedItem,
        iconDisabledColor: Colors.white,
        iconEnabledColor: Colors.white,
        dropdownColor: Colors.blue,
        underline: const SizedBox(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                  child: Text(itemLabel(item)),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
