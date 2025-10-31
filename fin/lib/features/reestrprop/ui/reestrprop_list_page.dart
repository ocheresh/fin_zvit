import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fin/core/models/reestrprop.dart';

import 'package:fin/features/references/mvi/reference_viewmodel.dart';
import 'package:fin/features/references/mvi/reference_intent.dart' as r;
import '../../signers/mvi/signer_viewmodel.dart';
import '../../signers/mvi/signer_intent.dart';
import 'package:fin/features/reestrprop/mvi/reestrprop_viewmodel.dart';
import 'package:fin/features/reestrprop/mvi/reestrprop_intent.dart';

import './widgets/view_helpers.dart';
import './widgets/filter_bar.dart';
import './widgets/responsive_list.dart';
import './widgets/reestr_prop_form.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

const String refKeyKpkv = 'КПКВ';
const String refKeyFunds = 'Фонд';

class ReestrPropListPage extends StatefulWidget {
  const ReestrPropListPage({super.key});
  @override
  State<ReestrPropListPage> createState() => _ReestrPropListPageState();
}

class _ReestrPropListPageState extends State<ReestrPropListPage> {
  String? _filterKpkvId;
  String? _filterFundId;
  int? _filterMonth;
  int? _filterSeqNo;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      html.document.title = 'Реєстр пропозицій | FinZvit';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReestrPropViewModel>().dispatch(const RPLoad());
      final rv = context.read<ReferenceViewModel>();
      if (rv.state.data.isEmpty) rv.dispatch(r.LoadAll());
      context.read<SignerViewModel>().dispatch(const LoadAll());
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<ReestrPropViewModel>().state;

    // Довідники (id -> name)
    final refs = context.watch<ReferenceViewModel>().state.data;
    final kpkvMap = toIdNameMap(refs[refKeyKpkv]);
    final fundMap = toIdNameMap(refs[refKeyFunds]);

    // Підписанти для пошуку (id -> lastName)
    final signers = context.watch<SignerViewModel>().state.items ?? const [];
    final signerName = {
      for (final s in signers) '${s.id}': (s.lastName ?? '').trim(),
    };

    // Опції фільтрів (унікальні)
    final items = st.items;
    final uniqueSeq = {...items.map((e) => e.seqNo)}.toList()..sort();
    final uniqueKpkv = {...items.map((e) => e.kpkvId)}.toList()..sort();
    final uniqueFund = {...items.map((e) => e.fundId)}.toList()..sort();

    // Локальна фільтрація
    final q = _searchText.trim().toLowerCase();
    final filtered = items.where((p) {
      if (_filterSeqNo != null && p.seqNo != _filterSeqNo) return false;
      if (_filterKpkvId != null && p.kpkvId != _filterKpkvId) return false;
      if (_filterFundId != null && p.fundId != _filterFundId) return false;
      if (_filterMonth != null && p.month != _filterMonth) return false;

      if (q.isEmpty) return true;

      final monthIdx = (p.month - 1).clamp(0, 11);
      final haystack = [
        '${p.seqNo}',
        kpkvMap[p.kpkvId] ?? p.kpkvId,
        fundMap[p.fundId] ?? p.fundId,
        monthsShort[monthIdx],
        monthsFull[monthIdx],
        signerName[p.signFirstId] ?? p.signFirstId,
        signerName[p.signSecondId] ?? p.signSecondId,
      ].join(' ').toLowerCase();

      return haystack.contains(q);
    }).toList();

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
          // 🔎 Панель фільтрів + пошук
          FilterBar(
            kpkvOptions: uniqueKpkv,
            fundOptions: uniqueFund,
            monthOptions: List<int>.generate(12, (i) => i + 1),
            seqOptions: uniqueSeq,
            kpkvId: _filterKpkvId,
            fundId: _filterFundId,
            month: _filterMonth,
            seqNo: _filterSeqNo,
            // searchText: _searchText,
            // onSearchChanged: (s) => setState(() => _searchText = s),
            kpkvLabelOf: (id) => refName(kpkvMap, id),
            fundLabelOf: (id) => refName(fundMap, id),
            onChanged: (k, f, m, n) => setState(() {
              _filterKpkvId = k;
              _filterFundId = f;
              _filterMonth = m;
              _filterSeqNo = n;
            }),
            onClear: () => setState(() {
              _filterKpkvId = null;
              _filterFundId = null;
              _filterMonth = null;
              _filterSeqNo = null;
              _searchText = '';
            }),
          ),
          Expanded(
            child: st.loading && st.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ResponsivePropList(
                    items: filtered,
                    kpkvMap: kpkvMap,
                    fundMap: fundMap,
                    openEdit: _openEdit,
                    onDelete: _confirmDelete,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Додати'),
      ),
    );
  }

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
    if (ok) context.read<ReestrPropViewModel>().dispatch(RPDelete(id));
  }

  Future<void> _openCreate(BuildContext context) async {
    final r = await showModalBottomSheet<FormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ReestrPropForm(),
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
    final r = await showModalBottomSheet<FormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReestrPropForm(initial: p),
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
