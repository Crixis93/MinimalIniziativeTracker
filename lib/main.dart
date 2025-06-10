import 'package:flutter/material.dart';

void main() {
  runApp(const InitiativeTrackerApp());
}

class InitiativeTrackerApp extends StatelessWidget {
  const InitiativeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Initiative Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InitiativePage(),
    );
  }
}

class InitiativeEntry {
  String name;
  int initiative;

  InitiativeEntry({required this.name, required this.initiative});
}

class InitiativePage extends StatefulWidget {
  const InitiativePage({super.key});

  @override
  State<InitiativePage> createState() => _InitiativePageState();
}

class _InitiativePageState extends State<InitiativePage> {
  final List<InitiativeEntry> _entries = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initController = TextEditingController();

  void _addEntry() {
    final name = _nameController.text.trim();
    final initiative = int.tryParse(_initController.text.trim());
    if (name.isEmpty || initiative == null) return;

    setState(() {
      _entries.add(InitiativeEntry(name: name, initiative: initiative));
      _nameController.clear();
      _initController.clear();
    });
  }

  void _editEntry(int index) {
    final entry = _entries[index];
    final editNameController = TextEditingController(text: entry.name);
    final editInitController =
        TextEditingController(text: entry.initiative.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica elemento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editNameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: editInitController,
              decoration: const InputDecoration(labelText: 'Iniziativa'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              final newName = editNameController.text.trim();
              final newInit = int.tryParse(editInitController.text.trim());
              if (newName.isNotEmpty && newInit != null) {
                setState(() {
                  entry.name = newName;
                  entry.initiative = newInit;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initiative Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _initController,
              decoration: const InputDecoration(labelText: 'Iniziativa'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addEntry,
              child: const Text('Aggiungi'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return ListTile(
                    title: Text(entry.name),
                    subtitle: Text('Iniziativa: ${entry.initiative}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editEntry(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
