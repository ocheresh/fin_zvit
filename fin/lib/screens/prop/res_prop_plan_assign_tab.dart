import 'package:flutter/material.dart';
import 'package:fin/services/api_service.dart'; // твій ApiService

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

  List<Map<String, dynamic>> data = [];
  bool _isLoading = true;
  String currentQuery = "";

  final Map<String, String> kekvDict = {
    "0000": "Невідомо", // fallback
    "2240": "Оплата послуг",
    "2260": "Комунальні послуги",
    "3110": "Закупівля обладнання",
    "3120": "Будівництво",
    "3130": "Послуги",
    "3140": "Оплата праці",
    "3150": "Інші видатки",
  };

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
      final plans = await apiService.fetchResPlans(
        widget.year,
        widget.kpkv,
        widget.fund,
      );

      if (!mounted) return;
      setState(() {
        // Дані вже готові – просто присвоюємо
        data = List<Map<String, dynamic>>.from(plans);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print(e);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  String _monthFromDate(String dateStr) {
    try {
      final monthIndex = DateTime.parse(dateStr).month;
      const months = [
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
      ];
      return months[monthIndex - 1];
    } catch (_) {
      return "Не визначено";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          final totalSum = proposal["rows"].fold<int>(
            0,
            (sum, row) => sum + row["vsogo"] as int,
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
                        "Пропозиція № ${proposal["id"]} за ${proposal["month"]} ${proposal["year"]}",
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
                          enabled: !proposal["approved"],
                          onPressed: () {
                            if (!mounted) return;
                            debugPrint(
                              "Відхилено пропозицію № ${proposal["id"]}",
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          label: "Видалити",
                          color: Colors.grey,
                          enabled: !proposal["approved"],
                          onPressed: () {
                            if (!mounted) return;
                            setState(() => data.removeAt(index));
                            debugPrint(
                              "Видалено пропозицію № ${proposal["id"]}",
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          label: "Затвердити",
                          color: Colors.green,
                          enabled: !proposal["approved"],
                          onPressed: () {
                            if (!mounted) return;
                            setState(() => proposal["approved"] = true);
                            debugPrint(
                              "Затверджено пропозицію № ${proposal["id"]}",
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButtonWithIcon(
                          label: "Сформувати пропозиції",
                          color: Colors.green,
                          icon: Icons.file_download,
                          onPressed: () {
                            debugPrint(
                              "Файл пропозицій сформовано для № ${proposal["id"]}",
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _actionButtonWithIcon(
                          label: "Сформувати детальні розрахунки",
                          color: Colors.green,
                          icon: Icons.file_download,
                          onPressed: () {
                            debugPrint(
                              "Детальні розрахунки сформовано для № ${proposal["id"]}",
                            );
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
                        proposal["filteredRows"] = proposal["rows"]
                            .where(
                              (row) =>
                                  row["vidomchyiKod"].toString().contains(
                                    query,
                                  ) ||
                                  row["kekv"].toString().contains(query) ||
                                  row["nameRozporyad"]
                                      .toString()
                                      .toLowerCase()
                                      .contains(query.toLowerCase()),
                            )
                            .toList();
                      });
                    },
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columnWidth = constraints.maxWidth / headers.length;
                    final rowsToShow =
                        proposal["filteredRows"] ?? proposal["rows"];

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade400),
                        columnWidths: {
                          for (int i = 0; i < headers.length; i++)
                            i: FixedColumnWidth(columnWidth),
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
                                _highlightCell(
                                  row["vidomchyiKod"].toString(),
                                  currentQuery,
                                ),
                                _highlightCell(
                                  row["nameRozporyad"].toString(),
                                  currentQuery,
                                ),
                                _expensesDropdown(row),
                                _highlightCell(
                                  row["kekv"].toString(),
                                  currentQuery,
                                ),
                                _highlightCell(row["vsogo"].toString(), null),
                                ...row["months"].entries.map(
                                  (e) =>
                                      _highlightCell(e.value.toString(), null),
                                ),
                                _highlightCell(row["notes"].toString(), null),
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

  Widget _expensesDropdown(Map<String, dynamic> row) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DropdownButton<String>(
        value: row["kekv"] != null && kekvDict.containsKey(row["kekv"])
            ? row["kekv"]
            : "0000", // fallback якщо немає
        isExpanded: true,
        items: kekvDict.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  "${entry.key} — ${entry.value}",
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (!mounted) return;
          if (value != null) {
            setState(() {
              row["kekv"] = value;
              row["nameVytrat"] = kekvDict[value] ?? "Невідомо";
            });
          }
        },
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onPressed,
  }) => ElevatedButton(
    onPressed: enabled
        ? () {
            if (!mounted) return;
            onPressed();
          }
        : null,
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

  Widget _actionButtonWithIcon({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) => ElevatedButton.icon(
    onPressed: () {
      if (!mounted) return;
      onPressed();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: const Size(80, 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    icon: Icon(icon, size: 16),
    label: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );
}
