import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';

class AddGoalViewModel extends ChangeNotifier {
  final _uuid = const Uuid();

  String name = '';
  String description = '';
  double targetAmount = 0.0;
  int iconCode = 57746; // savings icon
  String colorHex = '#2E7D32';
  DateTime? deadline;
  bool _isSaving = false;
  String? _error;

  bool get isSaving => _isSaving;
  String? get error => _error;

  bool get isValid =>
      name.trim().isNotEmpty && targetAmount > 0;

  void setName(String v)          { name = v; notifyListeners(); }
  void setDescription(String v)   { description = v; notifyListeners(); }
  void setTargetAmount(double v)  { targetAmount = v; notifyListeners(); }
  void setIconCode(int v)         { iconCode = v; notifyListeners(); }
  void setColorHex(String v)      { colorHex = v; notifyListeners(); }
  void setDeadline(DateTime? v)   { deadline = v; notifyListeners(); }

  Future<bool> save(GoalRepository repo) async {
    if (!isValid) return false;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final goal = Goal(
        id: _uuid.v4(),
        name: name.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        targetAmount: targetAmount,
        iconCode: iconCode,
        colorHex: colorHex,
        deadline: deadline,
        createdAt: DateTime.now(),
      );
      await repo.insertGoal(goal);
      return true;
    } catch (e) {
      _error = 'Erreur lors de la sauvegarde : $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void reset() {
    name = '';
    description = '';
    targetAmount = 0.0;
    iconCode = 57746;
    colorHex = '#2E7D32';
    deadline = null;
    _error = null;
    notifyListeners();
  }
}
