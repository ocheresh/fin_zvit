import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/core/models/reference_item.dart';
import '../mvi/reference_viewmodel.dart';
import '../mvi/reference_intent.dart';

class ReferenceListPage extends StatefulWidget {
  const ReferenceListPage({super.key});
  @override
  State<ReferenceListPage> createState() => _ReferenceListPageState();
}

class _ReferenceListPageState extends State<ReferenceListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ReferenceViewModel>().dispatch(LoadAll()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReferenceViewModel>();
    final st = vm.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Довідники')),
      body: st.loading
          ? const Center(child: CircularProgressIndicator())
          : st.error != null
          ? Center(child: Text('Помилка: ${st.error}'))
          : ListView(
              children: st.data.entries
                  .map((e) => _buildCategory(context, e.key, e.value, vm))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await _askText(context, 'Нова категорія');
          if (name != null && name.isNotEmpty) {
            vm.dispatch(CreateCategory(name));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String category,
    List<ReferenceItem> items,
    ReferenceViewModel vm,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  final newName = await _askText(
                    context,
                    'Перейменувати категорію',
                    initial: category,
                  );
                  if (newName != null &&
                      newName.isNotEmpty &&
                      newName != category) {
                    // створити нову → перенести елементи → видалити стару (з підтвердженням)
                    await vm.dispatch(CreateCategory(newName));
                    for (final it in items) {
                      // додавання без id — генерується на бекенді
                      await vm.dispatch(
                        AddItem(newName, name: it.name, info: it.info),
                      );
                    }
                    final ok = await _confirm(
                      context,
                      'Видалити стару категорію "$category"?',
                    );
                    if (ok) {
                      await vm.dispatch(DeleteCategory(category));
                    }
                  }
                } else if (v == 'delete') {
                  final ok = await _confirm(
                    context,
                    'Видалити категорію "$category" та всі її елементи?',
                  );
                  if (ok) vm.dispatch(DeleteCategory(category));
                } else if (v == 'add') {
                  // єдине вікно: назва + інфо, id не питаємо
                  final data = await _itemDialog(
                    context,
                    title: 'Новий елемент у "$category"',
                  );
                  if (data != null) {
                    vm.dispatch(
                      AddItem(
                        category,
                        name: data['name']!,
                        info: data['info'] ?? '',
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Перейменувати'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Видалити категорію'),
                  ),
                ),
                PopupMenuItem(
                  value: 'add',
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Додати елемент'),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          for (final it in items)
            ListTile(
              title: Text(it.name),
              subtitle: it.info.isNotEmpty ? Text(it.info) : null,
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    // один діалог для редагування
                    final data = await _itemDialog(
                      context,
                      title: 'Редагувати елемент',
                      initialName: it.name,
                      initialInfo: it.info,
                    );
                    if (data != null) {
                      await vm.dispatch(
                        EditItem(
                          category,
                          it.id,
                          name: data['name'],
                          info: data['info'],
                        ),
                      );
                    }
                  } else if (v == 'delete') {
                    final ok = await _confirm(
                      context,
                      'Видалити елемент "${it.name}"?',
                    );
                    if (ok) {
                      await vm.dispatch(DeleteItem(category, it.id));
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Редагувати'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Видалити'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _askText(
    BuildContext context,
    String title, {
    String? initial,
  }) async {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>?> _itemDialog(
    BuildContext context, {
    String title = 'Елемент',
    String initialName = '',
    String initialInfo = '',
  }) async {
    final nameC = TextEditingController(text: initialName);
    final infoC = TextEditingController(text: initialInfo);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Назва *'),
            ),
            TextField(
              controller: infoC,
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
            onPressed: () {
              final name = nameC.text.trim();
              if (name.isEmpty) return; // обовʼязкове поле
              Navigator.pop(context, {'name': name, 'info': infoC.text.trim()});
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String question) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Підтвердження'),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ні'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Так'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
