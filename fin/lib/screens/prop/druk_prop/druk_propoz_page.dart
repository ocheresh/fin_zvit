import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DrukPropozPage extends StatefulWidget {
  const DrukPropozPage({super.key});

  @override
  State<DrukPropozPage> createState() => _DrukPropozPageState();
}

class _DrukPropozPageState extends State<DrukPropozPage> {
  final _fmtUAH = NumberFormat.currency(
    locale: 'uk_UA',
    symbol: '₴',
    decimalDigits: 2,
  );

  // 🔹 Тестові дані (надалі можна підключити до репозиторію)
  final _proposals = [
    {
      'id': 1,
      'number': 'ПР-2025-001',
      'total': 1250000.50,
      'central': 830000.0,
      'decentral': 420000.5,
    },
    {
      'id': 2,
      'number': 'ПР-2025-002',
      'total': 987654.32,
      'central': 500000.0,
      'decentral': 487654.32,
    },
  ];

  Map<String, dynamic>? _current;

  @override
  void initState() {
    super.initState();
    _current = _proposals.first;
  }

  String _s(double v) => _fmtUAH.format(v);

  void _stub(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('🔹 $msg (заглушка)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Друк пропозиції')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔸 1 частина: вибір пропозиції, сума, кнопка друку
            Row(
              children: [
                // Номер пропозиції
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Номер пропозиції',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        value: _current,
                        items: _proposals
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e['number'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _current = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Загальна сума
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    readOnly: true,
                    initialValue: _s(_current?['total'] ?? 0),
                    key: ValueKey(_current?['id']),
                    decoration: const InputDecoration(
                      labelText: 'Загальна сума',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Кнопка друку
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _stub('Друк пропозиції'),
                    icon: const Icon(Icons.print),
                    label: const Text('Друк пропозиції'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),

            // 🔸 2 частина: Централізована оплата
            _SectionCard(
              title: 'Розрахунки (централізована оплата)',
              amount: _current?['central'] ?? 0,
              format: _s,
              onPrint: () => _stub('Друк централізованої оплати'),
            ),

            const SizedBox(height: 12),

            // 🔸 3 частина: Децентралізована оплата
            _SectionCard(
              title: 'Розрахунки (децентралізована оплата)',
              amount: _current?['decentral'] ?? 0,
              format: _s,
              onPrint: () => _stub('Друк децентралізованої оплати'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final double amount;
  final String Function(double) format;
  final VoidCallback onPrint;

  const _SectionCard({
    required this.title,
    required this.amount,
    required this.format,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Загальна сума: ${format(amount)}'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print),
                label: const Text('Друк'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
