import 'package:flutter/material.dart';

void main() {
  runApp(const MinimalIniziativeTrackerApp());
}

class Creature {
  Creature(this.name, this.initiative);

  final String name;
  final int initiative;
}

class MinimalIniziativeTrackerApp extends StatelessWidget {
  const MinimalIniziativeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Iniziative Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IniziativeTrackerPage(),
    );
  }
}

class IniziativeTrackerPage extends StatefulWidget {
  const IniziativeTrackerPage({super.key});

  @override
  State<IniziativeTrackerPage> createState() => _IniziativeTrackerPageState();
}

class _IniziativeTrackerPageState extends State<IniziativeTrackerPage> {
  final List<Creature> _creatures = [];

  void _showAddDialog() {
    final nameController = TextEditingController();
    final initiativeController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aggiungi Creatura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: initiativeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Iniziativa'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final initiative = int.tryParse(initiativeController.text.trim());
                if (name.isNotEmpty && initiative != null) {
                  setState(() {
                    _creatures.add(Creature(name, initiative));
                    _creatures.sort(
                        (a, b) => b.initiative.compareTo(a.initiative));
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Iniziative Tracker'),
      ),
      body: ListView.builder(
        itemCount: _creatures.length,
        itemBuilder: (context, index) {
          final creature = _creatures[index];
          return ListTile(
            title: Text(creature.name),
            trailing: Text(creature.initiative.toString()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
