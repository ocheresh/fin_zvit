import 'package:flutter/material.dart';
import 'finance_table.dart';

class FinanceTablePage extends StatelessWidget {
  const FinanceTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: FinanceTableFixedScaleHighlighted()),
    );
  }
}
