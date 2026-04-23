import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primaires
  static const Color primary        = Color(0xFF2E7D32);
  static const Color primaryLight   = Color(0xFF81C784);
  static const Color primaryDark    = Color(0xFF1B5E20);

  // États
  static const Color success        = Color(0xFF4CAF50);
  static const Color error          = Color(0xFFE53935);
  static const Color warning        = Color(0xFFFB8C00);
  static const Color info           = Color(0xFF1976D2);

  // Neutres
  static const Color background     = Color(0xFFF5F5F5);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF212121);
  static const Color textSecondary  = Color(0xFF757575);
  static const Color divider        = Color(0xFFE0E0E0);

  // Palette objectifs (couleurs au choix)
  static const List<Color> goalColors = [
    Color(0xFF2E7D32), // Vert
    Color(0xFF1976D2), // Bleu
    Color(0xFF7B1FA2), // Violet
    Color(0xFFE53935), // Rouge
    Color(0xFFF57C00), // Orange
    Color(0xFF00838F), // Cyan
  ];

  static const List<String> goalColorHexes = [
    '#2E7D32',
    '#1976D2',
    '#7B1FA2',
    '#E53935',
    '#F57C00',
    '#00838F',
  ];
}
