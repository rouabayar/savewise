import '../../core/database/database_helper.dart';
import '../models/goal.dart';

class GoalRepository {
  final DatabaseHelper _db;
  GoalRepository(this._db);

  /// Récupère tous les objectifs actifs avec leur montant épargné calculé
  Future<List<Goal>> getActiveGoals() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
             COALESCE(SUM(c.amount), 0) AS current_amount
      FROM goals g
      LEFT JOIN contributions c ON c.goal_id = g.id
      WHERE g.status = 'active'
      GROUP BY g.id
      ORDER BY g.sort_order ASC, g.created_at ASC
    ''');
    return rows.map(Goal.fromMap).toList();
  }

  /// Récupère les objectifs archivés ou complétés
  Future<List<Goal>> getArchivedGoals() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
             COALESCE(SUM(c.amount), 0) AS current_amount
      FROM goals g
      LEFT JOIN contributions c ON c.goal_id = g.id
      WHERE g.status IN ('completed', 'archived')
      GROUP BY g.id
      ORDER BY g.created_at DESC
    ''');
    return rows.map(Goal.fromMap).toList();
  }

  /// Récupère un objectif par son ID
  Future<Goal?> getGoalById(String id) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT g.*,
             COALESCE(SUM(c.amount), 0) AS current_amount
      FROM goals g
      LEFT JOIN contributions c ON c.goal_id = g.id
      WHERE g.id = ?
      GROUP BY g.id
    ''', [id]);
    if (rows.isEmpty) return null;
    return Goal.fromMap(rows.first);
  }

  /// Crée un nouvel objectif
  Future<void> insertGoal(Goal goal) async {
    final db = await _db.database;
    await db.insert('goals', goal.toMap());
  }

  /// Met à jour un objectif existant
  Future<void> updateGoal(Goal goal) async {
    final db = await _db.database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Archive un objectif (soft delete)
  Future<void> archiveGoal(String id) async {
    final db = await _db.database;
    await db.update(
      'goals',
      {'status': 'archived'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marque un objectif comme complété
  Future<void> completeGoal(String id) async {
    final db = await _db.database;
    await db.update(
      'goals',
      {'status': 'completed'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime définitivement un objectif (et ses contributions via CASCADE)
  Future<void> deleteGoal(String id) async {
    final db = await _db.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  /// Résumé global : total épargné tous objectifs actifs
  Future<double> getTotalSaved() async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(c.amount), 0) AS total
      FROM contributions c
      JOIN goals g ON g.id = c.goal_id
      WHERE g.status = 'active'
    ''');
    return (result.first['total'] as num).toDouble();
  }
}
