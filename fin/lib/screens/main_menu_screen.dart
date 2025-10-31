import 'package:flutter/material.dart';
import '../features/acoounts/ui/account_list_page.dart';
import '../features/references/ui/reference_list_page.dart';
import '../features/signers/ui/signers_registry_page.dart';
import '../features/reestrprop/ui/reestrprop_list_page.dart';

import 'plan/plan_selection_screen.dart';
import 'prop/prop_budget_tabs_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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
            SizedBox(height: 40),
            Row(
              children: [
                _buildMenuButton(
                  context,
                  icon: Icons.bar_chart,
                  title:
                      'Кошторис, план асигнувань та взяті бюджетні зобовязання',
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
              ],
            ),

            Row(
              children: [
                _buildMenuButton(
                  context,
                  icon: Icons.rebase_edit,
                  title: 'Реєстрація пропозицій',
                  description: 'Нумерація, створення, редагування пропозицій',
                  onTap: () {
                    if (kIsWeb) {
                      html.window.open(
                        '/#/reestrprop',
                        '_blank',
                      ); // відкриє ReestrPropListPage у новій вкладці
                    } else {
                      Navigator.pushNamed(context, '/reestrprop');
                    }
                  },
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.queue_play_next_sharp,
                  title: 'Пропозиції',
                  description: 'Реєстр змін до кошторису та плану асигнувань',
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
              ],
            ),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.max,
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Особові рахунки',
                    description: 'Управління рахунками',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountListPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Підписанти',
                    description: 'Посадові особи які мають право підпису',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignersRegistryPage(),
                        ),
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
                        MaterialPageRoute(
                          builder: (context) => ReferenceListPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        // elevation: 2,
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
