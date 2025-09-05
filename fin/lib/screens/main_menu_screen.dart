import 'package:flutter/material.dart';
import 'account_list_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Кошторис ГУЗтК ГШ ЗСУ'),
        backgroundColor: Colors.blue[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 80,
              color: Colors.blue[700],
            ),
            SizedBox(height: 24),
            Text(
              'Головне меню',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 40),
            _buildMenuButton(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Особові рахунки',
              description: 'Управління фінансовими рахунками',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountListScreen()),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.bar_chart,
              title: 'Звіти та аналітика',
              description: 'Перегляд фінансових звітів',
              onTap: () {
                _showComingSoon(context, 'Звіти та аналітика');
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.settings,
              title: 'Налаштування',
              description: 'Налаштування системи',
              onTap: () {
                _showComingSoon(context, 'Налаштування');
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.help,
              title: 'Довідка',
              description: 'Інформація про систему',
              onTap: () {
                _showComingSoon(context, 'Довідка');
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
          title: Text('$featureName'),
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