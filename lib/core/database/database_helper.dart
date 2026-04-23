import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'savewise.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        icon_code   INTEGER NOT NULL DEFAULT 57399,
        color_hex   TEXT NOT NULL DEFAULT '#2E7D32',
        deadline    TEXT,
        status      TEXT NOT NULL DEFAULT 'active',
        created_at  TEXT NOT NULL,
        sort_order  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE contributions (
        id             TEXT PRIMARY KEY,
        goal_id        TEXT NOT NULL,
        amount         REAL NOT NULL,
        note           TEXT,
        contributed_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
      )
    ''');

    // Seed data : 3 objectifs de démonstration
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration v1 -> v2 (exemple futur)
    // if (oldVersion < 2) { await db.execute('ALTER TABLE goals ADD COLUMN ...'); }
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final goals = [
      {
        'id': 'seed-1',
        'name': 'Voyage au Japon',
        'description': 'Tokyo, Kyoto, Osaka — rêve de toujours',
        'target_amount': 2500.0,
        'icon_code': 58723,   // flight
        'color_hex': '#1976D2',
        'deadline': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'status': 'active',
        'created_at': now,
        'sort_order': 0,
      },
      {
        'id': 'seed-2',
        'name': 'Nouveau PC portable',
        'description': 'MacBook Pro pour le développement',
        'target_amount': 1800.0,
        'icon_code': 57481,   // laptop
        'color_hex': '#7B1FA2',
        'deadline': null,
        'status': 'active',
        'created_at': now,
        'sort_order': 1,
      },
      {
        'id': 'seed-3',
        'name': "Fonds d'urgence",
        'description': '3 mois de dépenses de côté',
        'target_amount': 3000.0,
        'icon_code': 57746,   // savings
        'color_hex': '#2E7D32',
        'deadline': null,
        'status': 'active',
        'created_at': now,
        'sort_order': 2,
      },
    ];

    for (final g in goals) {
      await db.insert('goals', g);
    }

    final contributions = [
      {'id': 'c-1', 'goal_id': 'seed-1', 'amount': 300.0, 'note': 'Janvier', 'contributed_at': now},
      {'id': 'c-2', 'goal_id': 'seed-1', 'amount': 150.0, 'note': 'Février', 'contributed_at': now},
      {'id': 'c-3', 'goal_id': 'seed-1', 'amount': 200.0, 'note': 'Mars',    'contributed_at': now},
      {'id': 'c-4', 'goal_id': 'seed-2', 'amount': 500.0, 'note': 'Prime',   'contributed_at': now},
      {'id': 'c-5', 'goal_id': 'seed-2', 'amount': 300.0, 'note': 'Avril',   'contributed_at': now},
      {'id': 'c-6', 'goal_id': 'seed-3', 'amount': 200.0, 'note': 'Janvier', 'contributed_at': now},
      {'id': 'c-7', 'goal_id': 'seed-3', 'amount': 200.0, 'note': 'Février', 'contributed_at': now},
      {'id': 'c-8', 'goal_id': 'seed-3', 'amount': 200.0, 'note': 'Mars',    'contributed_at': now},
      {'id': 'c-9', 'goal_id': 'seed-1', 'amount': 100.0, 'note': 'Extra',   'contributed_at': now},
      {'id': 'c-10','goal_id': 'seed-3', 'amount': 150.0, 'note': 'Bonus',   'contributed_at': now},
    ];

    for (final c in contributions) {
      await db.insert('contributions', c);
    }
  }
}
