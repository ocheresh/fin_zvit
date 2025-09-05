import 'package:flutter/material.dart';
import '../services/reference_api_service.dart';
import '../models/reference_item.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  final ReferenceApiService apiService = ReferenceApiService(
    "http://localhost:3000",
  );

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
      final fetched = await apiService.fetchCategories();
      setState(() {
        categories = fetched;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка завантаження: $e')));
    }
  }

  void _addOrEditItem(String category, {ReferenceItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final infoController = TextEditingController(text: item?.info ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Додати елемент' : 'Редагувати елемент'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextField(
              controller: infoController,
              decoration: const InputDecoration(labelText: 'Інформація'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              if (item == null) {
                await apiService.addItem(
                  category,
                  nameController.text,
                  info: infoController.text,
                );
              } else {
                await apiService.updateItem(
                  category,
                  item.id,
                  nameController.text,
                  info: infoController.text,
                );
              }

              Navigator.pop(context);
              _loadCategories();
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String category, String itemId) async {
    await apiService.deleteItem(category, itemId);
    _loadCategories();
  }

  Widget _buildCategory(String category, List<ReferenceItem> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          for (var i = 0; i < items.length; i++)
            ListTile(
              title: Text(items[i].name),
              subtitle: items[i].info.isNotEmpty ? Text(items[i].info) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _addOrEditItem(category, item: items[i]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(category, items[i].id),
                  ),
                ],
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Додати новий елемент'),
            onTap: () => _addOrEditItem(category),
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
        title: const Text('Довідники'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        children: categories.entries
            .map((e) => _buildCategory(e.key, e.value))
            .toList(),
      ),
    );
  }
}
