import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/reestrprop.dart';
import '../../../core/models/reference_item.dart';
import '../../../core/models/signer.dart';

import '../../references/mvi/reference_viewmodel.dart';
import '../../references/mvi/reference_intent.dart' as r;

import '../../signers/mvi/signer_viewmodel.dart';
import '../../signers/mvi/signer_intent.dart';

import '../mvi/reestrprop_viewmodel.dart';
import '../mvi/reestrprop_intent.dart';

/// Ключі довідників у ReferenceViewModel.state.data
const String refKeyKpkv = 'КПКВ';
const String refKeyFunds = 'Фонд';

class ReestrPropListPage extends StatefulWidget {
  const ReestrPropListPage({super.key});

  @override
  State<ReestrPropListPage> createState() => _ReestrPropListPageState();
}

class _ReestrPropListPageState extends State<ReestrPropListPage> {
  @override
  void initState() {
    super.initState();
    // Викликаємо завантаження після побудови першого фрейму
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Реєстр пропозицій
      context.read<ReestrPropViewModel>().dispatch(const RPLoad());

      // Довідники (КПКВ/Фонд)
      final rv = context.read<ReferenceViewModel>();
      if (rv.state.data.isEmpty) {
        rv.dispatch(r.LoadAll());
      }

      // Підписанти (окрема база)
      final sv = context.read<SignerViewModel>();
      sv.dispatch(const LoadAll());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReestrPropViewModel>();
    final st = vm.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Реєстр пропозицій')),
      body: Column(
        children: [
          if (st.loading) const LinearProgressIndicator(minHeight: 2),
          if (st.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text('Помилка: ${st.error}')),
                  TextButton(
                    onPressed: () => context
                        .read<ReestrPropViewModel>()
                        .dispatch(const RPLoad()),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: st.loading && st.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(st.items),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        label: const Text('Додати'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTable(List<ReestrProp> items) {
    // 1) Підтягнемо всіх підписантів
    final signerVm = context.watch<SignerViewModel>();
    final List<Signer> signers = signerVm.state.items ?? const <Signer>[];

    // 2) Підготуємо мапи: id → прізвище
    final Map<String, String> firstMap = {
      for (final s in signers.where((s) => s.signRight == 'first'))
        '${s.id}': (s.lastName ?? '').trim(),
    };
    final Map<String, String> secondMap = {
      for (final s in signers.where((s) => s.signRight == 'second'))
        '${s.id}': (s.lastName ?? '').trim(),
    };

    String _sig(Map<String, String> m, String id) {
      final v = m[id];
      if (v != null && v.isNotEmpty) return v;
      // fallback: якщо не знайдено — показати сам id або порожньо
      return id.isEmpty ? '' : id;
    }

    const months = [
      'Січ',
      'Лют',
      'Бер',
      'Квіт',
      'Трав',
      'Чер',
      'Лип',
      'Серп',
      'Вер',
      'Жовт',
      'Лист',
      'Груд',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('№')),
          DataColumn(label: Text('КПКВ')),
          DataColumn(label: Text('Фонд')),
          DataColumn(label: Text('Місяць')),
          DataColumn(label: Text('1-й підпис')),
          DataColumn(label: Text('2-й підпис')),
          DataColumn(label: Text('Відпр. ДФ')),
          DataColumn(label: Text('Прийн. ДФ')),
          DataColumn(label: Text('Дії')),
        ],
        rows: items.map((p) {
          return DataRow(
            cells: [
              DataCell(Text('${p.seqNo}')),
              DataCell(Text(p.kpkvId)),
              DataCell(Text(p.fundId)),
              DataCell(Text(months[(p.month - 1).clamp(0, 11)])),
              DataCell(Text(_sig(firstMap, p.signFirstId))), // ← прізвище
              DataCell(Text(_sig(secondMap, p.signSecondId))), // ← прізвище
              DataCell(Text(p.sentDfDate == null ? '' : _fmt(p.sentDfDate!))),
              DataCell(
                Text(p.acceptedDfDate == null ? '' : _fmt(p.acceptedDfDate!)),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openEdit(context, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, p.id),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Видалити запис?'),
            content: const Text('Дію неможливо скасувати.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Видалити'),
              ),
            ],
          ),
        ) ??
        false;
    if (ok) {
      context.read<ReestrPropViewModel>().dispatch(RPDelete(id));
    }
  }

  Future<void> _openCreate(BuildContext context) async {
    final r = await showModalBottomSheet<_FormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ReestrPropForm(),
    );
    if (r != null) {
      context.read<ReestrPropViewModel>().dispatch(
        RPCreate(
          kpkvId: r.kpkvId,
          fundId: r.fundId,
          month: r.month,
          signFirstId: r.signFirstId,
          signSecondId: r.signSecondId,
          sentDf: r.sentDf,
          acceptedDf: r.acceptedDf,
        ),
      );
    }
  }

  Future<void> _openEdit(BuildContext context, ReestrProp p) async {
    final r = await showModalBottomSheet<_FormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReestrPropForm(initial: p),
    );
    if (r != null) {
      final patch = {
        'kpkv_id': r.kpkvId,
        'fund_id': r.fundId,
        'month': r.month,
        'sign_first_id': r.signFirstId,
        'sign_second_id': r.signSecondId,
        'sent_df_date': r.sentDf?.toIso8601String().split('T').first,
        'accepted_df_date': r.acceptedDf?.toIso8601String().split('T').first,
      };
      context.read<ReestrPropViewModel>().dispatch(RPUpdate(p.id, patch));
    }
  }
}

class _FormResult {
  final String kpkvId, fundId, signFirstId, signSecondId;
  final int month;
  final DateTime? sentDf, acceptedDf;
  _FormResult({
    required this.kpkvId,
    required this.fundId,
    required this.month,
    required this.signFirstId,
    required this.signSecondId,
    this.sentDf,
    this.acceptedDf,
  });
}

class _ReestrPropForm extends StatefulWidget {
  final ReestrProp? initial;
  const _ReestrPropForm({this.initial});
  @override
  State<_ReestrPropForm> createState() => _ReestrPropFormState();
}

class _ReestrPropFormState extends State<_ReestrPropForm> {
  String? _kpkvId;
  String? _fundId;
  int _month = DateTime.now().month;
  String? _sign1;
  String? _sign2;
  DateTime? _sent;
  DateTime? _acc;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _kpkvId = i.kpkvId;
      _fundId = i.fundId;
      _month = i.month;
      _sign1 = i.signFirstId;
      _sign2 = i.signSecondId;
      _sent = i.sentDfDate;
      _acc = i.acceptedDfDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // КПКВ/Фонд із ReferenceViewModel
    final refVm = context.watch<ReferenceViewModel>();
    final refs = refVm.state.data;
    final List<DropdownMenuItem<String>> kpkvItems = _asDropdownItems(
      refs[refKeyKpkv],
    );
    final List<DropdownMenuItem<String>> fundItems = _asDropdownItems(
      refs[refKeyFunds],
    );

    // Підписанти з SignerViewModel (окрема база)
    final signerVm = context.watch<SignerViewModel>();
    final List<Signer> allSigners = signerVm.state.items ?? const <Signer>[];

    final List<DropdownMenuItem<String>> signerFirstItems = _asSignerItems(
      allSigners.where((s) => s.signRight == 'first').toList(),
    );

    final List<DropdownMenuItem<String>> signerSecondItems = _asSignerItems(
      allSigners.where((s) => s.signRight == 'second').toList(),
    );

    // Перевірка готовності
    final bool isReady =
        kpkvItems.isNotEmpty &&
        fundItems.isNotEmpty &&
        signerFirstItems.isNotEmpty &&
        signerSecondItems.isNotEmpty;

    // Скидаємо значення, якщо їх немає у відповідних списках (змінились довідники)
    final kpkvVals = kpkvItems.map((e) => e.value).toSet();
    final fundVals = fundItems.map((e) => e.value).toSet();
    final s1Vals = signerFirstItems.map((e) => e.value).toSet();
    final s2Vals = signerSecondItems.map((e) => e.value).toSet();
    if (_kpkvId != null && !kpkvVals.contains(_kpkvId)) _kpkvId = null;
    if (_fundId != null && !fundVals.contains(_fundId)) _fundId = null;
    if (_sign1 != null && !s1Vals.contains(_sign1)) _sign1 = null;
    if (_sign2 != null && !s2Vals.contains(_sign2)) _sign2 = null;

    final pad = EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      left: 16,
      right: 16,
      top: 16,
    );

    if (!isReady) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    const months = [
      'Січень',
      'Лютий',
      'Березень',
      'Квітень',
      'Травень',
      'Червень',
      'Липень',
      'Серпень',
      'Вересень',
      'Жовтень',
      'Листопад',
      'Грудень',
    ];

    return SingleChildScrollView(
      padding: pad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.initial == null
                ? 'Нова пропозиція'
                : 'Редагувати пропозицію',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _Dropdown<String>(
                  label: 'КПКВ',
                  value: _kpkvId,
                  items: kpkvItems,
                  onChanged: (v) => setState(() => _kpkvId = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Dropdown<String>(
                  label: 'Фонд',
                  value: _fundId,
                  items: fundItems,
                  onChanged: (v) => setState(() => _fundId = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _Dropdown<int>(
                  label: 'Місяць',
                  value: _month,
                  items: List.generate(
                    12,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text(months[i])),
                  ),
                  onChanged: (v) => setState(() => _month = v ?? _month),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _Dropdown<String>(
                  label: 'Перший підпис',
                  value: _sign1,
                  items: signerFirstItems,
                  onChanged: (v) => setState(() => _sign1 = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Dropdown<String>(
                  label: 'Другий підпис',
                  value: _sign2,
                  items: signerSecondItems,
                  onChanged: (v) => setState(() => _sign2 = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Дата відправки в ДФ',
                  value: _sent,
                  onPick: (d) => setState(() => _sent = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatePickerField(
                  label: 'Дата прийняття ДФ',
                  value: _acc,
                  onPick: (d) => setState(() => _acc = d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Скасувати'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                child: const Text('Зберегти'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _kpkvId != null && _fundId != null && _sign1 != null && _sign2 != null;

  void _submit() {
    Navigator.pop(
      context,
      _FormResult(
        kpkvId: _kpkvId!,
        fundId: _fundId!,
        month: _month,
        signFirstId: _sign1!,
        signSecondId: _sign2!,
        sentDf: _sent,
        acceptedDf: _acc,
      ),
    );
  }

  /// КПКВ/Фонд: показуємо тільки name
  List<DropdownMenuItem<String>> _asDropdownItems(List<ReferenceItem>? list) {
    if (list == null) return const [];
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];

    for (final e in list) {
      final id = '${e.id}'.trim();
      if (id.isEmpty) continue;
      if (!seen.add(id)) continue;

      final label = (e.name ?? '').trim();
      items.add(
        DropdownMenuItem<String>(
          value: id,
          child: Text(label.isEmpty ? id : label),
        ),
      );
    }
    return items;
  }

  /// Підписанти: у дропдауні показуємо тільки прізвище
  List<DropdownMenuItem<String>> _asSignerItems(List<Signer> list) {
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];
    for (final s in list) {
      final id = '${s.id}'.trim();
      if (id.isEmpty) continue;
      if (!seen.add(id)) continue;

      final last = (s.lastName ?? '').trim(); // тільки прізвище
      final label = last.isEmpty ? id : last;

      items.add(DropdownMenuItem<String>(value: id, child: Text(label)));
    }
    return items;
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPick,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              firstDate: DateTime(now.year - 2),
              lastDate: DateTime(now.year + 2),
              initialDate: value ?? now,
            );
            onPick(d);
          },
          child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            child: Text(
              value == null
                  ? '—'
                  : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
      ],
    );
  }
}
