import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/database/database_helper.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/contribution_repository.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/goal_detail_viewmodel.dart';
import 'viewmodels/add_goal_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper.instance;
  await db.database; // initialise la BD au démarrage

  runApp(
    MultiProvider(
      providers: [
        Provider<GoalRepository>(
          create: (_) => GoalRepository(db),
        ),
        Provider<ContributionRepository>(
          create: (_) => ContributionRepository(db),
        ),
        ChangeNotifierProxyProvider2<GoalRepository, ContributionRepository,
            DashboardViewModel>(
          create: (ctx) => DashboardViewModel(
            ctx.read<GoalRepository>(),
            ctx.read<ContributionRepository>(),
          ),
          update: (_, goalRepo, contribRepo, vm) =>
          vm!..update(goalRepo, contribRepo),
        ),
        ChangeNotifierProvider(create: (_) => AddGoalViewModel()),
        ChangeNotifierProvider(create: (_) => GoalDetailViewModel()),
      ],
      child: const SaveWiseApp(),
    ),
  );
}