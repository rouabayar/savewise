// ============================================================
// lib/views/archive/archive_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/models/goal.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Goal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goals =
        await context.read<GoalRepository>().getArchivedGoals();
    setState(() { _goals = goals; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archives')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.archive_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Aucun objectif archivé',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _goals.length,
                  itemBuilder: (_, i) {
                    final g = _goals[i];
                    final color = Color(
                        int.parse(g.colorHex.replaceFirst('#', '0xFF')));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                            IconData(g.iconCode, fontFamily: 'MaterialIcons'),
                            color: color),
                        title: Text(g.name),
                        subtitle: Text(
                          '${g.currentAmount.toStringAsFixed(0)} € / ${g.targetAmount.toStringAsFixed(0)} €',
                        ),
                        trailing: Chip(
                          label: Text(
                            g.status == 'completed' ? 'Atteint' : 'Abandonné',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: g.status == 'completed'
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
