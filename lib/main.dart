import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Iniziative Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitiativeTracker(),
    );
  }
}

class Creature {
  final String name;
  final int initiative;
  Creature({required this.name, required this.initiative});
}

class InitiativeTracker extends StatefulWidget {
  const InitiativeTracker({super.key});

  @override
  State<InitiativeTracker> createState() => _InitiativeTrackerState();
}

class _InitiativeTrackerState extends State<InitiativeTracker> {
  final List<Creature> _creatures = [];

  @override
  void initState() {
    super.initState();
    _loadCreatures();
  }

  Future<void> _loadCreatures() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('creatures');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _creatures.clear();
        _creatures.addAll(decoded.map((e) => Creature(name: e['name'], initiative: e['initiative'])));
      });
    }
  }

  Future<void> _saveCreatures() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_creatures.map((c) => {'name': c.name, 'initiative': c.initiative}).toList());
    await prefs.setString('creatures', data);
  }

  void _addCreature(String name, int initiative) {
    setState(() {
      _creatures.add(Creature(name: name, initiative: initiative));
      _creatures.sort((a, b) => b.initiative.compareTo(a.initiative));
    });
    _saveCreatures();
  }

  void _showAddDialog() {
    String defaultName = '';
    if (_creatures.isNotEmpty) {
      defaultName = _creatures.last.name;
    }
    final nameController = TextEditingController(text: defaultName);
    int selectedInitiative = _creatures.isNotEmpty ? _creatures.last.initiative : 0;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Creature'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    autofocus: true,
                    onSubmitted: (value) {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        _addCreature(name, selectedInitiative);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: selectedInitiative,
                    isExpanded: true,
                    items: [
                      for (int i = -10; i <= 50; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(i.toString()),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedInitiative = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      _addCreature(name, selectedInitiative);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeInitiativeDialog(int index) {
    int selectedInitiative = _creatures[index].initiative;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Change Initiative'),
              content: DropdownButton<int>(
                value: selectedInitiative,
                isExpanded: true,
                items: [
                  for (int i = -10; i <= 50; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(i.toString()),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setStateDialog(() {
                      selectedInitiative = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final c = _creatures[index];
                      _creatures[index] = Creature(name: c.name, initiative: selectedInitiative);
                      _creatures.sort((a, b) => b.initiative.compareTo(a.initiative));
                    });
                    _saveCreatures();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeNameDialog(int index) {
    final nameController = TextEditingController(text: _creatures[index].name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            autofocus: true,
            onSubmitted: (value) {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  final c = _creatures[index];
                  _creatures[index] = Creature(name: name, initiative: c.initiative);
                });
                _saveCreatures();
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    final c = _creatures[index];
                    _creatures[index] = Creature(name: name, initiative: c.initiative);
                  });
                  _saveCreatures();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: const Text('Do you really want to delete creature?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _creatures.clear();
              });
              _saveCreatures();
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _creatures.isEmpty
          ? const Center(child: Text('No creatures added.'))
          : ListView.builder(
              itemCount: _creatures.length,
              itemBuilder: (context, index) {
                final c = _creatures[index];
                return Column(
                  children: [
                    ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          _showChangeInitiativeDialog(index);
                        },
                        child: CircleAvatar(child: Text(c.initiative.toString())),
                      ),
                      title: GestureDetector(
                        onTap: () {
                          _showChangeNameDialog(index);
                        },
                        child: Text(c.name),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete all creatures',
                            onPressed: () {
                              setState(() {
                                _creatures.removeAt(index);
                              });
                              _saveCreatures();
                            },
                          ),
                        ],
                      ),
                    ),
                    if (index < _creatures.length - 1) const Divider(),
                  ],
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'deleteAll',
            onPressed: _showDeleteAllDialog,
            tooltip: 'Delete all creatures',
            child: const Icon(Icons.delete_forever),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: _showAddDialog,
            tooltip: 'Add Creature',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
