import 'package:flutter/material.dart';
import '../../models/prop_plan_assign.dart';
import '../../models/reference_item.dart';
import '../../models/account.dart';
import '../../services/prop_plan_assign_service.dart';
import '../../services/api_service.dart';
import '../../services/reference_api_service.dart';
import 'dart:convert';

class PropPlanAssignTab extends StatefulWidget {
  final int year;
  final ReferenceItem kpkv;
  final ReferenceItem fund;

  final VoidCallback? onPropozCompleted;

  PropPlanAssignTab({
    super.key,
    required this.year,
    required this.kpkv,
    required this.fund,
    this.onPropozCompleted,
  });

  @override
  State<PropPlanAssignTab> createState() => _PropPlanAssignTabState();
}

class _PropPlanAssignTabState extends State<PropPlanAssignTab> {
  late final PropPlanAssignService service;
  late final ApiService apiService;
  late final ReferenceApiService refApiService;

  List<PropPlanAssign> data = [];
  bool isLoading = true;
  String _searchQuery = '';
  ReferenceItem? selectedKekv;
  final TextEditingController _searchController = TextEditingController();

  // Поле для кнопки "Обрати всі"
  bool _allSelected = false;

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
    "Обрати",
  ];

  @override
  void initState() {
    super.initState();
    service = PropPlanAssignService("http://localhost:3000");
    apiService = ApiService("http://localhost:3000");
    refApiService = ReferenceApiService("http://localhost:3000");
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await service.fetchPlans(
        widget.year,
        widget.kpkv.name,
        widget.fund.name,
      );
      for (var p in plans) {
        p.isSelected = false;
      }
      setState(() {
        data = plans;
        isLoading = false;
        _allSelected = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  void _toggleSelectAll() {
    setState(() {
      _allSelected = !_allSelected;
      for (var row in filteredData) {
        row.isSelected = _allSelected;
      }
    });
  }

  List<PropPlanAssign> get filteredData {
    if (_searchQuery.isEmpty) return data;
    return data
        .where(
          (row) =>
              row.accountId.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              row.kekvId.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _showDetails(PropPlanAssign row) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Деталі рядка"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Особовий рахунок: ${row.accountId}"),
              Text("Назва: ${row.legalName}"),
              Text("КЕКВ: ${row.kekvId}"),
              Text("Місяці: ${row.months.join(', ')}"),
              Text("Всього: ${row.total}"),
              if ((row.additionalInfo ?? '').isNotEmpty)
                Text("Додаткова інформація: ${row.additionalInfo}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Закрити"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _editPlanDialog(row);
            },
            icon: const Icon(Icons.edit),
            label: const Text("Редагувати"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
            onPressed: () {
              Navigator.pop(context);
              _deletePlan(row);
            },
            icon: const Icon(Icons.delete),
            label: const Text("Видалити"),
          ),
        ],
      ),
    );
  }

  Future<void> _editPlanDialog(PropPlanAssign plan) async {
    final additionalInfoCtrl = TextEditingController(text: plan.additionalInfo);
    final monthCtrls = List.generate(
      12,
      (i) => TextEditingController(text: plan.months[i].toString()),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Редагувати рядок"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < 12; i++)
                TextField(
                  controller: monthCtrls[i],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Місяць ${i + 1}"),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: additionalInfoCtrl,
                decoration: const InputDecoration(
                  labelText: "Додаткова інформація",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Скасувати"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final updatedMonths = monthCtrls
                  .map((c) => int.tryParse(c.text) ?? 0)
                  .toList();
              final updatedPlan = PropPlanAssign(
                id: plan.id,
                accountId: plan.accountId,
                legalName: plan.legalName,
                kekvId: plan.kekvId,
                months: updatedMonths,
                additionalInfo: additionalInfoCtrl.text,
                isSelected: plan.isSelected,
              );
              try {
                final saved = await service.updatePlan(
                  widget.year,
                  widget.kpkv.name,
                  widget.fund.name,
                  updatedPlan,
                );
                setState(() {
                  final index = data.indexWhere((p) => p.id == plan.id);
                  if (index != -1) data[index] = saved;
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка редагування: $e')),
                );
              }
            },
            icon: const Icon(Icons.save),
            label: const Text("Зберегти"),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan(PropPlanAssign plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Підтвердити видалення"),
        content: Text(
          "Ви впевнені, що хочете видалити рядок з рахунком ${plan.accountId} та КЕКВ ${plan.kekvId}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Скасувати"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete),
            label: const Text("Видалити"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await service.deletePlan(
        widget.year,
        widget.kpkv.name,
        widget.fund.name,
        plan.id!,
      );
      setState(() {
        data.removeWhere((p) => p.id == plan.id);
        _allSelected = filteredData.every((p) => p.isSelected);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Рядок успішно видалено")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка видалення: $e')));
    }
  }

  bool _isProcessing = false; // додати у _PropPlanAssignTabState

  Future<void> _addPropoz() async {
    if (_isProcessing) return;
    final selectedRows = data.where((row) => row.isSelected).toList();
    if (selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Оберіть зміни — пропозиція не може бути опрацьована'),
        ),
      );
      return;
    }

    int newNumber;
    String newNumberStr;

    try {
      final lastPropoz = await apiService.getLastPropoz();
      final lastNumber = lastPropoz?['number'] ?? 0;
      newNumber = lastNumber + 1;
      newNumberStr = newNumber.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка отримання останньої пропозиції: $e')),
      );
      return;
    }

    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Додати пропозицію',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Номер пропозиції: $newNumberStr',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Примітка (необов’язково)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(context, noteController.text.trim()),
              child: const Text('Провести зміни'),
            ),
          ],
        );
      },
    );

    if (note == null) return;

    setState(() => _isProcessing = true);

    try {
      await apiService.addPropoz(
        newNumber,
        note,
        widget.kpkv.name,
        widget.fund.name,
      );

      // ⚡ Перетворюємо всі рядки у чисті Map перед відправкою
      final items = selectedRows
          .map(
            (row) =>
                jsonDecode(jsonEncode(row.toJson())) as Map<String, dynamic>,
          )
          .toList();

      await apiService.addResPropoz(
        items,
        widget.year,
        widget.kpkv.name,
        widget.fund.name,
        newNumberStr,
      );

      for (var row in selectedRows) {
        if (row.id != null) {
          await service.deletePlan(
            widget.year,
            widget.kpkv.name,
            widget.fund.name,
            row.id!,
          );
        }
      }

      setState(() {
        data.removeWhere((row) => selectedRows.contains(row));
        _allSelected = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пропозиція №$newNumberStr проведена, вибрані рядки видалено.',
          ),
        ),
      );

      if (widget.onPropozCompleted != null) {
        widget.onPropozCompleted!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при проведенні пропозиції: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _addPlanDialog() async {
    List<Account> accounts = [];
    Account? selectedAccount;
    final additionalInfoCtrl = TextEditingController();
    final monthCtrls = List.generate(12, (_) => TextEditingController());
    selectedKekv = null;

    try {
      accounts = await apiService.fetchAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Помилка завантаження акаунтів: $e")),
      );
      return;
    }

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
                    if (textEditingValue.text.isEmpty)
                      return const Iterable<Account>.empty();
                    return accounts.where((acc) {
                      final query = textEditingValue.text.toLowerCase();
                      return acc.accountNumber.toLowerCase().contains(query) ||
                          acc.rozporiadNumber.toLowerCase().contains(query);
                    });
                  },
                  displayStringForOption: (acc) =>
                      "${acc.accountNumber} - ${acc.rozporiadNumber}",
                  onSelected: (acc) => selectedAccount = acc,
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
                ),
                const SizedBox(height: 8),
                Autocomplete<ReferenceItem>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty)
                      return const Iterable<ReferenceItem>.empty();
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
                  displayStringForOption: (item) => item.name,
                  onSelected: (item) => selectedKekv = item,
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(labelText: "КЕКВ"),
                        );
                      },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: additionalInfoCtrl,
                  decoration: const InputDecoration(
                    labelText: "Додаткова інформація",
                  ),
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
              onPressed: () async {
                if (selectedAccount == null || selectedKekv == null) return;
                final months = monthCtrls
                    .map((c) => int.tryParse(c.text) ?? 0)
                    .toList();
                final newPlan = PropPlanAssign(
                  id: "",
                  accountId:
                      "${selectedAccount!.accountNumber} / ${selectedAccount!.rozporiadNumber}",
                  legalName: selectedAccount!.legalName,
                  kekvId: selectedKekv!.name,
                  months: months,
                  additionalInfo: additionalInfoCtrl.text,
                  isSelected: false,
                );
                try {
                  final created = await service.addPlan(
                    year: widget.year,
                    kpkv: widget.kpkv.name,
                    fund: widget.fund.name,
                    plan: newPlan,
                  );
                  setState(() {
                    data.add(created);
                    _allSelected = filteredData.every((p) => p.isSelected);
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Помилка додавання: $e')),
                  );
                }
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

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    int totalSum = filteredData.fold(0, (sum, item) => sum + item.total);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Сума всіх "Всього": $totalSum')),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: Text("Контрольна сума: $totalSum"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addPlanDialog,
                icon: const Icon(Icons.add),
                label: const Text("Додати"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isProcessing ? null : _addPropoz,
                icon: _isProcessing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add_card_sharp),
                label: Text(_isProcessing ? 'Обробка...' : 'Провести зміни'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
                onPressed: _toggleSelectAll,
                icon: Icon(
                  _allSelected
                      ? Icons.check_box_outline_blank
                      : Icons.check_box,
                ),
                label: Text(_allSelected ? "Зняти всі" : "Обрати всі"),
              ),
              const SizedBox(width: 8),
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
                      final rowValues = [
                        row.accountId,
                        row.kekvId,
                        ...row.months,
                        row.total,
                      ];
                      return InkWell(
                        onTap: () => _showDetails(row),
                        child: Row(
                          children: [
                            ...rowValues.map(
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
                            ),
                            Container(
                              width: columnWidth,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Checkbox(
                                value: row.isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    row.isSelected = value ?? false;
                                    _allSelected = filteredData.every(
                                      (p) => p.isSelected,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
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
