import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'widgets/goal_card.dart';
import 'widgets/summary_banner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mes objectifs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<DashboardViewModel>().loadGoals(),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(vm.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.loadGoals,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: vm.loadGoals,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SummaryBanner(
                    totalSaved: vm.totalSaved,
                    totalTarget: vm.totalTarget,
                    goalCount: vm.totalGoals,
                    progress: vm.globalProgress,
                  ),
                ),
                if (vm.goals.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.savings_outlined,
                              size: 72,
                              color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun objectif pour l\'instant\nAppuie sur + pour commencer !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => GoalCard(
                          goal: vm.goals[i],
                          onTap: () => context.push('/goal/${vm.goals[i].id}'),
                          onArchive: () => _confirmArchive(context, vm, vm.goals[i].id),
                        ),
                        childCount: vm.goals.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/goal/new');
          if (context.mounted) {
            context.read<DashboardViewModel>().loadGoals();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvel objectif'),
      ),
    );
  }

  void _confirmArchive(BuildContext context, DashboardViewModel vm, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Archiver l\'objectif ?'),
        content: const Text('L\'objectif sera déplacé dans les archives.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.archiveGoal(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Objectif archivé')),
              );
            },
            child: const Text('Archiver', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
