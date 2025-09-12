import 'package:flutter/material.dart';
import '../../models/reference_item.dart';
import 'package:fin/screens/prop/prop_plan_assign_tab.dart';
import 'prop_rozpodil_tabs_screen.dart';
import 'res_prop_plan_assign_tab.dart';

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text(
          'Параметри: ${widget.year}, ${widget.kpkv.name}, ${widget.fund.name}',
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
            // Tab(text: 'Пропозиції до розподілу'),
            // Tab(text: 'Розподіл'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // передаємо параметри у вкладку
          PropPlanAssignTab(
            year: widget.year,
            kpkv: widget.kpkv,
            fund: widget.fund,
            onPropozCompleted: () {
              _tabController.animateTo(1); // 1 — індекс ResPropPlanPage
            },
          ),
          ResPropPlanPage(
            year: widget.year,
            kpkv: widget.kpkv.name,
            fund: widget.fund.name,
          ),
          // const Center(child: Text('Сторінка "Зміни кошторису"')),
          // const PropRozpodilScreen(),
          // const Center(child: Text('Сторінка "Розподіл"')),
        ],
      ),
    );
  }
}
