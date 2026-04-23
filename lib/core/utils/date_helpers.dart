import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static final _dateFormat     = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final _shortFormat    = DateFormat('dd MMM yyyy', 'fr_FR');
  static final _monthFormat    = DateFormat('MMMM yyyy', 'fr_FR');

  /// "15/04/2026"
  static String format(DateTime date) => _dateFormat.format(date);

  /// "15 avr. 2026"
  static String formatShort(DateTime date) => _shortFormat.format(date);

  /// "avril 2026"
  static String formatMonth(DateTime date) => _monthFormat.format(date);

  /// Nombre de jours restants jusqu'à une date
  static int daysUntil(DateTime deadline) =>
      deadline.difference(DateTime.now()).inDays;

  /// "dans 45 jours" | "il y a 3 jours" | "aujourd'hui"
  static String relativeLabel(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff == 0) return "aujourd'hui";
    if (diff > 0)  return 'dans $diff jour${diff > 1 ? 's' : ''}';
    return 'il y a ${diff.abs()} jour${diff.abs() > 1 ? 's' : ''}';
  }

  /// Convertit des semaines en label lisible : 3 → "3 semaines", 52 → "~1 an"
  static String weeksToLabel(int weeks) {
    if (weeks <= 0)  return 'objectif atteint !';
    if (weeks == 1)  return '1 semaine';
    if (weeks < 5)   return '$weeks semaines';
    if (weeks < 9)   return '${(weeks / 4).round()} mois';
    if (weeks < 52)  return '${(weeks / 4.33).round()} mois';
    final years = (weeks / 52).toStringAsFixed(1);
    return '~$years an${double.parse(years) >= 2 ? 's' : ''}';
  }
}
