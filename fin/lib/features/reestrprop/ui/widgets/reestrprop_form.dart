import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/reestrprop.dart';
import '../../../../core/models/reference_item.dart';

import '../../../references/mvi/reference_viewmodel.dart';

import 'label_dropdown.dart';
import 'date_picker_field.dart';

const String refKeyKpkv = 'КПКВ';
const String refKeyFunds = 'Фонд';
const String refKeySigners = 'signers';

class ReestrPropFormResult {
  final String kpkvId, fundId, signFirstId, signSecondId; // ← String
  final int month; // ← int
  final DateTime? sentDf, acceptedDf;
  ReestrPropFormResult({
    required this.kpkvId,
    required this.fundId,
    required this.month,
    required this.signFirstId,
    required this.signSecondId,
    this.sentDf,
    this.acceptedDf,
  });
}

class ReestrPropForm extends StatefulWidget {
  final ReestrProp? initial;
  const ReestrPropForm({super.key, this.initial});

  @override
  State<ReestrPropForm> createState() => _ReestrPropFormState();
}

class _ReestrPropFormState extends State<ReestrPropForm> {
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
    final refVm = context.watch<ReferenceViewModel>();
    final refs = refVm.state.data;

    final kpkvItems = _asDropdownItems(refs[refKeyKpkv]);
    final fundItems = _asDropdownItems(refs[refKeyFunds]);
    final signerItems = _asDropdownItems(refs[refKeySigners]);

    final isRefsReady =
        kpkvItems.isNotEmpty && fundItems.isNotEmpty && signerItems.isNotEmpty;

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
    final pad = EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      left: 16,
      right: 16,
      top: 16,
    );

    if (!isRefsReady) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // скинути value, якщо його немає в items (на випадок зміни справочника)
    final kpkvVals = kpkvItems.map((e) => e.value).toSet();
    final fundVals = fundItems.map((e) => e.value).toSet();
    final signerVals = signerItems.map((e) => e.value).toSet();
    if (_kpkvId != null && !kpkvVals.contains(_kpkvId)) _kpkvId = null;
    if (_fundId != null && !fundVals.contains(_fundId)) _fundId = null;
    if (_sign1 != null && !signerVals.contains(_sign1)) _sign1 = null;
    if (_sign2 != null && !signerVals.contains(_sign2)) _sign2 = null;

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
                child: LabelDropdown<String>(
                  label: 'КПКВ',
                  value: _kpkvId,
                  items: kpkvItems,
                  onChanged: (v) => setState(() => _kpkvId = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabelDropdown<String>(
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
                child: LabelDropdown<int>(
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
                child: LabelDropdown<String>(
                  label: 'Перший підпис',
                  value: _sign1,
                  items: signerItems,
                  onChanged: (v) => setState(() => _sign1 = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabelDropdown<String>(
                  label: 'Другий підпис',
                  value: _sign2,
                  items: signerItems,
                  onChanged: (v) => setState(() => _sign2 = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  label: 'Дата відправки в ДФ',
                  value: _sent,
                  onPick: (d) => setState(() => _sent = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DatePickerField(
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
      ReestrPropFormResult(
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

  // ТЕПЕР String-ідентифікатори без фільтрації по int
  List<DropdownMenuItem<String>> _asDropdownItems(List<ReferenceItem>? list) {
    if (list == null) return const [];
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];
    for (final e in list) {
      final id = '${e.id}'.trim();
      if (id.isEmpty) continue;
      if (!seen.add(id)) continue;
      final label = _bestLabel(e).isEmpty ? id : _bestLabel(e);
      items.add(DropdownMenuItem<String>(value: id, child: Text(label)));
    }
    return items;
  }

  String _bestLabel(ReferenceItem e) {
    final parts = <String>[];
    if ((e.name ?? '').isNotEmpty) parts.add(e.name!);
    if ((e.info ?? '').isNotEmpty) parts.add(e.info!);

    return parts.join(' — ');
  }
}
