import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../core/models/reference_item.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  Map<String, List<ReferenceItem>> categories = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final jsonString = await rootBundle.loadString('assets/references.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      setState(() {
        categories = data.map((key, value) {
          final list = (value as List)
              .map(
                (e) => ReferenceItem(
                  id: e['id'],
                  name: e['name'],
                  info: e['info'] ?? '',
                ),
              )
              .toList();
          return MapEntry(key, list);
        });
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  Widget _buildCategory(String category, List<ReferenceItem> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert), // три крапки
              onSelected: (value) {
                if (value == 'edit') {
                  // 🔹 Редагування категорії
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Редагувати категорію"),
                      content: Text("Тут редагуємо: $category"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Скасувати"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Зберегти зміни
                            Navigator.pop(context);
                          },
                          child: const Text("Зберегти"),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'delete') {
                  // 🔹 Видалення категорії
                  setState(() {
                    categories.remove(category);
                  });
                } else if (value == 'add') {
                  // 🔹 Додавання нового елемента
                  // _addOrEditItem(category);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.green),
                    title: Text("Редагувати"),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text("Видалити"),
                  ),
                ),
                const PopupMenuItem(
                  value: 'add',
                  child: ListTile(
                    leading: Icon(Icons.add, color: Colors.blue),
                    title: Text("Додати елемент"),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          for (var i = 0; i < items.length; i++)
            ListTile(
              title: Text(items[i].name),
              subtitle: items[i].info.isNotEmpty ? Text(items[i].info) : null,
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    // _addOrEditItem(category, item: items[i]);
                  } else if (value == 'delete') {
                    // _deleteItem(category, items[i].id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.green),
                      title: Text("Редагувати"),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text("Видалити"),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Довідники (локальні дані)'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        children: categories.entries
            .map((e) => _buildCategory(e.key, e.value))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
        onPressed: () {
          // 🔹 наприклад, можна відкрити діалог для створення нового довідника
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Додати категорію"),
              content: const Text(
                "Тут буде логіка для створення нового довідника",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Закрити"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
