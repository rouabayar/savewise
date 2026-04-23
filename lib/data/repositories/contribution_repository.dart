import '../../core/database/database_helper.dart';
import '../models/contribution.dart';

class ContributionRepository {
  final DatabaseHelper _db;
  ContributionRepository(this._db);

  /// Récupère tous les versements d'un objectif, du plus récent au plus ancien
  Future<List<Contribution>> getContributionsForGoal(String goalId) async {
    final db = await _db.database;
    final rows = await db.query(
      'contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'contributed_at DESC',
    );
    return rows.map(Contribution.fromMap).toList();
  }

  /// Ajoute un versement
  Future<void> insertContribution(Contribution contribution) async {
    final db = await _db.database;
    await db.insert('contributions', contribution.toMap());
  }

  /// Met à jour un versement
  Future<void> updateContribution(Contribution contribution) async {
    final db = await _db.database;
    await db.update(
      'contributions',
      contribution.toMap(),
      where: 'id = ?',
      whereArgs: [contribution.id],
    );
  }

  /// Supprime un versement
  Future<void> deleteContribution(String id) async {
    final db = await _db.database;
    await db.delete('contributions', where: 'id = ?', whereArgs: [id]);
  }

  /// Calcule la moyenne hebdomadaire sur les 4 dernières semaines
  Future<double> getWeeklyAverage(String goalId) async {
    final db = await _db.database;
    final fourWeeksAgo = DateTime.now()
        .subtract(const Duration(days: 28))
        .toIso8601String();
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) / 4.0 AS weekly_avg
      FROM contributions
      WHERE goal_id = ? AND contributed_at >= ?
    ''', [goalId, fourWeeksAgo]);
    return (result.first['weekly_avg'] as num).toDouble();
  }

  /// Historique mensuel agrégé pour les graphiques
  Future<List<Map<String, dynamic>>> getMonthlyHistory(String goalId) async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT
        strftime('%Y-%m', contributed_at) AS month,
        SUM(amount) AS total
      FROM contributions
      WHERE goal_id = ?
      GROUP BY month
      ORDER BY month ASC
    ''', [goalId]);
  }
}
