import 'package:flutter/material.dart';
import 'account_list_screen.dart';
import 'reference_screen.dart';
import 'prop/prop_selection_screen.dart';
import 'plan/plan_selection_screen.dart';
import 'prop/prop_budget_tabs_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Головне меню'),
        backgroundColor: Colors.blue[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.account_balance, size: 80, color: Colors.blue[700]),
            // SizedBox(height: 24),
            // Text(
            //   'Головне меню',
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blue[700],
            //   ),
            // ),
            SizedBox(height: 40),
            _buildMenuButton(
              context,
              icon: Icons.bar_chart,
              title: 'Кошторис, план асигнувань та взяті бюджетні зобовязання',
              description: 'Перегляд інформації',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanSelectionScreen(),
                  ),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.queue_play_next_sharp,
              title: 'Пропозиції',
              description: 'Реєстр змін',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // builder: (context) => PropSelectionScreen(),
                    builder: (context) => PropBudgetTabsScreen(),
                  ),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Особові рахунки',
              description: 'Управління рахунками',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountListScreen()),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.bookmark_add_rounded,
              title: 'Довідники',
              description: 'КПКВ, ФОНД, КЕКВ .....',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReferenceScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue[700]),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(featureName),
          content: Text('Цей розділ знаходиться в розробці.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
