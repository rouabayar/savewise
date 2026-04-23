import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(
            icon: Icons.savings,
            label: 'Total épargné',
            value: '${vm.totalSaved.toStringAsFixed(2)} €',
            color: const Color(0xFF2E7D32),
          ),
          _StatCard(
            icon: Icons.flag,
            label: 'Objectifs actifs',
            value: '${vm.totalGoals}',
            color: const Color(0xFF1976D2),
          ),
          _StatCard(
            icon: Icons.track_changes,
            label: 'Montant total cible',
            value: '${vm.totalTarget.toStringAsFixed(2)} €',
            color: const Color(0xFF7B1FA2),
          ),
          _StatCard(
            icon: Icons.percent,
            label: 'Progression globale',
            value: '${vm.globalProgress.toStringAsFixed(1)}%',
            color: const Color(0xFF00838F),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
