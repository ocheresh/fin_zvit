import 'package:flutter/material.dart';
import 'package:fin/services/api_service.dart';
import 'package:fin/models/res_propoz.dart';
import 'package:fin/models/reference_item.dart';
import 'package:fin/services/reference_api_service.dart';

class ResPropPlanPage extends StatefulWidget {
  final int year;
  final String kpkv;
  final String fund;

  const ResPropPlanPage._({
    super.key,
    required this.year,
    required this.kpkv,
    required this.fund,
  });

  factory ResPropPlanPage({
    Key? key,
    required int year,
    required String kpkv,
    required String fund,
  }) {
    String mappedFund;
    if (fund == 'Загальний') {
      mappedFund = 'ZF';
    } else if (fund == 'Спеціальний') {
      mappedFund = 'SF';
    } else {
      mappedFund = fund.replaceAll(RegExp(r'[^\w\d-]'), '_');
    }

    return ResPropPlanPage._(
      key: key,
      year: year,
      kpkv: kpkv,
      fund: mappedFund,
    );
  }

  @override
  State<ResPropPlanPage> createState() => _ResPropPlanPageState();
}

class _ResPropPlanPageState extends State<ResPropPlanPage> {
  late ApiService apiService;

  List<ResPropoz> data = [];
  bool _isLoading = true;
  String currentQuery = "";

  Map<String, List<String>> expensesDict = {};

  @override
  void initState() {
    super.initState();
    apiService = ApiService("http://localhost:3000");
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final references = await ReferenceApiService(
        "http://localhost:3000",
      ).fetchCategories();
      final plans = await apiService.fetchResPropoz(
        widget.year,
        widget.kpkv,
        widget.fund,
      );

      // будуємо словник витрат лише з KEKV_det для КЕКВ, що є в таблиці
      expensesDict = {};
      if (references.containsKey("KEKV_det")) {
        final kekvRows = plans
            .expand((proposal) => proposal.rows)
            .map((r) => r.kekv)
            .toSet();

        for (var item in references["KEKV_det"]!) {
          if (kekvRows.contains(item.name)) {
            expensesDict.putIfAbsent(item.name, () => []);
            if (item.info.isNotEmpty) expensesDict[item.name]!.add(item.info);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        data = plans;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final headers = [
      "Відомчий код",
      "Розпорядник",
      "Витрати",
      "КЕКВ",
      "Всього",
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
      "Примітки",
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final proposal = data[index];
          final rowsToShow = (proposal.filteredRows ?? proposal.rows)
              .whereType<ResPropozRow>()
              .toList();

          final totalSum = rowsToShow.fold<int>(
            0,
            (int sum, ResPropozRow row) => sum + (row.vsogo ?? 0),
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Пропозиція № ${proposal.id} за ${proposal.month} ${proposal.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Всього: $totalSum"),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _actionButton(
                          label: "Відхилити",
                          color: Colors.redAccent,
                          enabled: proposal.approved ?? true,
                          onPressed: () {
                            if (!mounted) return;
                            setState(() => proposal.approved = false);
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          label: "Видалити",
                          color: Colors.grey,
                          enabled: proposal.approved != true,
                          onPressed: () {
                            if (!mounted) return;
                            setState(() => data.removeAt(index));
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          label: "Затвердити",
                          color: Colors.green,
                          enabled: proposal.approved != true,
                          onPressed: () {
                            if (!mounted) return;
                            setState(() => proposal.approved = true);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText:
                          'Пошук по Відомчому коду, КЕКВ або Розпоряднику',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                    onChanged: (query) {
                      if (!mounted) return;
                      setState(() {
                        currentQuery = query;
                        proposal.filteredRows = proposal.rows
                            .where(
                              (row) =>
                                  row.vidomchyiKod.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ) ||
                                  row.kekv.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ) ||
                                  row.nameRozporyad.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ),
                            )
                            .toList();
                      });
                    },
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // визначаємо ширину для всіх колонок
                    final fixedColumnWidth =
                        150.0; // ширина для колонки Витрати
                    final otherColumns = headers.length - 1; // всі інші колонки
                    final adaptiveWidth =
                        (constraints.maxWidth - fixedColumnWidth) /
                        otherColumns;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade400),
                        columnWidths: {
                          for (int i = 0; i < headers.length; i++)
                            i: FixedColumnWidth(
                              headers[i] == "Витрати"
                                  ? fixedColumnWidth
                                  : adaptiveWidth,
                            ),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: headers
                                .map(
                                  (h) => Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(
                                      h,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          ...rowsToShow.map<TableRow>((row) {
                            return TableRow(
                              children: [
                                _highlightCell(row.vidomchyiKod, currentQuery),
                                _highlightCell(row.nameRozporyad, currentQuery),
                                _expensesDropdown(row), // фіксована ширина
                                _highlightCell(row.kekv, currentQuery),
                                _highlightCell(
                                  (row.vsogo ?? 0).toString(),
                                  null,
                                ),
                                ...row.months.entries
                                    .map(
                                      (e) => _highlightCell(
                                        (e.value ?? 0).toString(),
                                        null,
                                      ),
                                    )
                                    .toList(),
                                _highlightCell(row.notes ?? "", null),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _highlightCell(String value, String? query) {
    if (query == null || query.isEmpty) return _cell(value);

    final lowerValue = value.toLowerCase();
    final lowerQuery = query.toLowerCase();
    if (!lowerValue.contains(lowerQuery)) return _cell(value);

    final spans = <TextSpan>[];
    int start = 0, index;
    while ((index = lowerValue.indexOf(lowerQuery, start)) != -1) {
      if (index > start)
        spans.add(TextSpan(text: value.substring(start, index)));
      spans.add(
        TextSpan(
          text: value.substring(index, index + query.length),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ),
      );
      start = index + query.length;
    }
    if (start < value.length) spans.add(TextSpan(text: value.substring(start)));

    return Padding(
      padding: const EdgeInsets.all(6),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.black),
          children: spans,
        ),
      ),
    );
  }

  Widget _cell(String value) => Padding(
    padding: const EdgeInsets.all(6),
    child: Text(
      value,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 11),
    ),
  );

  Widget _expensesDropdown(ResPropozRow row) {
    final availableExpenses = expensesDict[row.kekv] ?? [""];

    final items = availableExpenses
        .map(
          (e) => DropdownMenuItem<String>(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 11)),
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DropdownButtonFormField<String>(
        value: availableExpenses.contains(row.nameVytrat)
            ? row.nameVytrat
            : availableExpenses.first,
        isExpanded: true,
        items: items,
        onChanged: (value) {
          if (!mounted || value == null) return;
          setState(() {
            row.nameVytrat = value;
          });
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onPressed,
  }) => ElevatedButton(
    onPressed: enabled ? onPressed : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: const Size(80, 30),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}
