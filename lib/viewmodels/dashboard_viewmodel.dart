import 'package:flutter/foundation.dart';
import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/contribution_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  GoalRepository _goalRepo;
  ContributionRepository _contribRepo;

  List<Goal> _goals = [];
  double _totalSaved = 0.0;
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  double get totalSaved => _totalSaved;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardViewModel(this._goalRepo, this._contribRepo) {
    loadGoals();
  }

  void update(GoalRepository goalRepo, ContributionRepository contribRepo) {
    _goalRepo = goalRepo;
    _contribRepo = contribRepo;
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _goals = await _goalRepo.getActiveGoals();
      _totalSaved = await _goalRepo.getTotalSaved();
    } catch (e) {
      _error = 'Impossible de charger les objectifs : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveGoal(String id) async {
    await _goalRepo.archiveGoal(id);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _goalRepo.deleteGoal(id);
    await loadGoals();
  }

  // Statistiques globales pour le banner
  int get totalGoals => _goals.length;
  double get totalTarget => _goals.fold(0, (s, g) => s + g.targetAmount);
  double get globalProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget * 100).clamp(0, 100) : 0;
}
