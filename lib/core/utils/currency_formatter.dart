import 'package:intl/intl.dart';

/// Utility for formatting currency values
class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
