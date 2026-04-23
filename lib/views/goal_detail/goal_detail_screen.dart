import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodels/goal_detail_viewmodel.dart';
import '../../data/models/contribution.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/contribution_repository.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalDetailViewModel>().loadGoal(
            widget.goalId,
            context.read<GoalRepository>(),
            context.read<ContributionRepository>(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GoalDetailViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (vm.goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Objectif introuvable')),
      );
    }

    final goal  = vm.goal!;
    final color = Color(
        int.parse(goal.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Ajouter un versement',
            onPressed: () => _showAddContribution(context, vm, color),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadGoal(
          widget.goalId,
          context.read<GoalRepository>(),
          context.read<ContributionRepository>(),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Carte de progression ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${goal.currentAmount.toStringAsFixed(2)} €',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: color)),
                        Text('sur ${goal.targetAmount.toStringAsFixed(2)} €',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progressPercent / 100,
                        minHeight: 12,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal.progressPercent.toStringAsFixed(1)}% atteint · '
                      'Il reste ${goal.remainingAmount.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Carte projection ---
            if (vm.estimatedWeeksRemaining != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: color, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Projection',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(
                              'À ce rythme, tu atteindras ton objectif dans '
                              '${vm.estimatedWeeksRemaining} semaine(s)',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // --- Graphique mensuel ---
            if (vm.monthlyHistory.isNotEmpty) ...[
              Text('Progression mensuelle',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        barGroups: vm.monthlyHistory
                            .asMap()
                            .entries
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (e.value['total'] as num).toDouble(),
                                      color: color,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ))
                            .toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx < 0 || idx >= vm.monthlyHistory.length)
                                  return const SizedBox.shrink();
                                final month =
                                    vm.monthlyHistory[idx]['month'] as String;
                                return Text(month.substring(5),
                                    style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // --- Historique des versements ---
            Text('Versements (${vm.contributions.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (vm.contributions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text('Aucun versement encore',
                          style: TextStyle(color: Colors.grey))),
                ),
              )
            else
              ...vm.contributions.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.12),
                        child: Icon(Icons.arrow_upward, color: color, size: 18),
                      ),
                      title: Text('+${c.amount.toStringAsFixed(2)} €',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: color)),
                      subtitle: Text(c.note ?? 'Versement'),
                      trailing: Text(
                        '${c.contributedAt.day}/${c.contributedAt.month}/${c.contributedAt.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showAddContribution(
      BuildContext context, GoalDetailViewModel vm, Color color) {
    final amountCtrl = TextEditingController();
    final noteCtrl   = TextEditingController();
    final formKey    = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ajouter un versement',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                    labelText: 'Montant (€) *',
                    prefixIcon: Icon(Icons.euro_outlined)),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                    labelText: 'Note (optionnel)',
                    prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final c = Contribution(
                      id: const Uuid().v4(),
                      goalId: widget.goalId,
                      amount: double.parse(amountCtrl.text),
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                      contributedAt: DateTime.now(),
                    );
                    Navigator.pop(context);
                    await vm.addContribution(
                      c,
                      context.read<GoalRepository>(),
                      context.read<ContributionRepository>(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Versement de ${c.amount.toStringAsFixed(2)} € ajouté !')),
                      );
                    }
                  },
                  child: const Text('Confirmer le versement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
