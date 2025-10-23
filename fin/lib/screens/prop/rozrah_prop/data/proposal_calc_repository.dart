import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/proposal_calc_item.dart';

class ProposalCalcRepository {
  final String assetPath;
  ProposalCalcRepository({this.assetPath = 'assets/proposal_calcs.json'});

  Future<List<ProposalCalcItem>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => ProposalCalcItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
