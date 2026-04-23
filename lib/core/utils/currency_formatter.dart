import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _compact = NumberFormat.compactCurrency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 0,
  );

  /// Formate un montant : 1500.5 → "1 500,50 €"
  static String format(double amount) => _formatter.format(amount);

  /// Format court : 1500.5 → "1,5 k€"
  static String compact(double amount) =>
      amount >= 1000 ? _compact.format(amount) : format(amount);

  /// Formate sans décimales si entier : 1500.0 → "1 500 €"
  static String formatSmart(double amount) {
    if (amount == amount.roundToDouble()) {
      return NumberFormat.currency(
        locale: 'fr_FR',
        symbol: '€',
        decimalDigits: 0,
      ).format(amount);
    }
    return format(amount);
  }
}
