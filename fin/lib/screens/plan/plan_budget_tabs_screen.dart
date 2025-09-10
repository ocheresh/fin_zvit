import 'package:flutter/material.dart';
import '../../models/reference_item.dart';
import 'plan_assign_tab.dart';

class PlanBudgetScreen extends StatefulWidget {
  final int year;
  final ReferenceItem kpkv;
  final ReferenceItem fund;

  const PlanBudgetScreen({
    super.key,
    required this.year,
    required this.kpkv,
    required this.fund,
  });

  @override
  State<PlanBudgetScreen> createState() => _PlanBudgetScreenState();
}

class _PlanBudgetScreenState extends State<PlanBudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: 'Кошторис'),
            Tab(text: 'План асигнувань'),
            Tab(text: 'Бюджетні зобовязання'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Сторінка "Кошторис"')),
          PlanAssignTab(),
          Center(child: Text('Сторінка "Пропозиції до розподілу"')),
        ],
      ),
    );
  }
}
