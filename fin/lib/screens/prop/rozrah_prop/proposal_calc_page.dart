// lib/rozrah_prop/pages/proposal_calc_page.dart
import 'package:flutter/material.dart';
import 'data/proposal_calc_repository.dart';
import 'viewmodels/proposal_calc_viewmodel.dart';
// import 'models/proposal_calc_item.dart';
import 'widgets/filters_row.dart';
import 'widgets/summary_table.dart' show SummaryBar;
import 'widgets/header_row.dart';
import 'widgets/proposal_row.dart';

class ProposalCalcPage extends StatefulWidget {
  const ProposalCalcPage({super.key});
  @override
  State<ProposalCalcPage> createState() => _ProposalCalcPageState();
}

class _ProposalCalcPageState extends State<ProposalCalcPage> {
  late final ProposalCalcViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ProposalCalcViewModel(repo: ProposalCalcRepository())..init();
    vm.addListener(_onVm);
  }

  @override
  void dispose() {
    vm.removeListener(_onVm);
    super.dispose();
  }

  void _onVm() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = vm.items;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SummaryBar(totalVsogo: vm.totalVsogo, count: vm.count),
              const SizedBox(height: 8),
              FiltersRow(
                current: vm.filters,
                onChanged: vm.setFilter,
                onClearAll: vm.clearFilters,
                optionsFor: vm.optionsFor,
              ),
              const SizedBox(height: 8),
              const TableHeaderRow(), // 👈 окремий віджет заголовка
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Немає даних'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => ProposalDataRow(item: items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
