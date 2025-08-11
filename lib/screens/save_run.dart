import 'package:flutter/material.dart';

class SaveRunScreen extends StatefulWidget {
  const SaveRunScreen({super.key});

  @override
  State<SaveRunScreen> createState() => _SaveRunScreenState();
}

class _SaveRunScreenState extends State<SaveRunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  void _save() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descController.text.trim();

      // TODO: save the run data somewhere or pass back

      Navigator.pop(context, {'name': name, 'description': description});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Your Run'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Run Name',
                  hintText: 'Enter a name for your run',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add notes or comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 200,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save Run'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
