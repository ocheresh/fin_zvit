import 'package:flutter/material.dart';
import 'package:fin/core/models/signer.dart';
import '../utils/signers_utils.dart';

class SignerDialog extends StatefulWidget {
  final Signer? initial;
  const SignerDialog({super.key, this.initial});
  @override
  State<SignerDialog> createState() => _SignerDialogState();
}

class _SignerDialogState extends State<SignerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _position;
  late final TextEditingController _rank;
  late final TextEditingController _lastName;
  late final TextEditingController _firstName;
  late final TextEditingController _fatherName;
  String _rightUi = 'Перше';

  @override
  void initState() {
    super.initState();
    _position = TextEditingController(text: widget.initial?.position ?? '');
    _rank = TextEditingController(text: widget.initial?.rank ?? '');
    _lastName = TextEditingController(text: widget.initial?.lastName ?? '');
    _firstName = TextEditingController(text: widget.initial?.firstName ?? '');
    _fatherName = TextEditingController(text: widget.initial?.fatherName ?? '');
    _rightUi = widget.initial == null
        ? 'Перше'
        : rightLabel(widget.initial!.signRight);
  }

  @override
  void dispose() {
    _position.dispose();
    _rank.dispose();
    _lastName.dispose();
    _firstName.dispose();
    _fatherName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return AlertDialog(
      title: Text(isEdit ? 'Редагувати підписанта' : 'Додати підписанта'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 840,
                  child: TextFormField(
                    controller: _position,
                    decoration: const InputDecoration(
                      labelText: 'Посада',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: TextFormField(
                    controller: _rank,
                    decoration: const InputDecoration(
                      labelText: 'Військове звання',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _rightUi,
                    items: const [
                      DropdownMenuItem(value: 'Перше', child: Text('Перше')),
                      DropdownMenuItem(value: 'Друге', child: Text('Друге')),
                    ],
                    onChanged: (v) => setState(() => _rightUi = v ?? 'Перше'),
                    decoration: const InputDecoration(
                      labelText: 'Право підпису',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 420,
                  child: TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(
                      labelText: 'Прізвище',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(
                      labelText: 'Імʼя',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _fatherName,
                    decoration: const InputDecoration(
                      labelText: 'По-батькові',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Зберегти' : 'Додати'),
        ),
      ],
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обовʼязкове поле' : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final result = Signer(
      id:
          widget.initial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      position: _position.text.trim(),
      rank: _rank.text.trim(),
      signRight: rightCode(_rightUi),
      lastName: _lastName.text.trim(),
      firstName: _firstName.text.trim(),
      fatherName: _fatherName.text.trim(),
    );
    Navigator.pop(context, result);
  }
}
