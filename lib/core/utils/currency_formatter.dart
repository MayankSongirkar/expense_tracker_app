import 'package:intl/intl.dart';

/// Utility for formatting currency values in Indian Rupees
class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
      locale: 'en_IN',
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##,###.00', 'en_IN');
    return formatter.format(amount);
  }
}
