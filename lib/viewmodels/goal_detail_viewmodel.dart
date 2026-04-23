import 'package:flutter/foundation.dart';
import '../data/models/goal.dart';
import '../data/models/contribution.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/contribution_repository.dart';

class GoalDetailViewModel extends ChangeNotifier {
  Goal? _goal;
  List<Contribution> _contributions = [];
  List<Map<String, dynamic>> _monthlyHistory = [];
  double _weeklyAverage = 0.0;
  bool _isLoading = false;
  String? _error;

  Goal? get goal => _goal;
  List<Contribution> get contributions => _contributions;
  List<Map<String, dynamic>> get monthlyHistory => _monthlyHistory;
  double get weeklyAverage => _weeklyAverage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int? get estimatedWeeksRemaining =>
      _goal?.estimatedWeeksRemaining(_weeklyAverage);

  Future<void> loadGoal(
    String goalId,
    GoalRepository goalRepo,
    ContributionRepository contribRepo,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _goal = await goalRepo.getGoalById(goalId);
      _contributions = await contribRepo.getContributionsForGoal(goalId);
      _monthlyHistory = await contribRepo.getMonthlyHistory(goalId);
      _weeklyAverage = await contribRepo.getWeeklyAverage(goalId);
    } catch (e) {
      _error = 'Erreur lors du chargement : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContribution(
    Contribution contribution,
    GoalRepository goalRepo,
    ContributionRepository contribRepo,
  ) async {
    await contribRepo.insertContribution(contribution);
    // Vérifie si l'objectif est atteint
    final updated = await goalRepo.getGoalById(contribution.goalId);
    if (updated != null && updated.isCompleted) {
      await goalRepo.completeGoal(contribution.goalId);
    }
    await loadGoal(contribution.goalId, goalRepo, contribRepo);
  }

  Future<void> deleteContribution(
    String contributionId,
    String goalId,
    GoalRepository goalRepo,
    ContributionRepository contribRepo,
  ) async {
    await contribRepo.deleteContribution(contributionId);
    await loadGoal(goalId, goalRepo, contribRepo);
  }
}
