import 'package:intl/intl.dart';

/// Utility functions for date operations
class DateHelper {
  static String formatDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  static String getMonthName(int month) {
    return DateFormat.MMMM().format(DateTime(2024, month));
  }
}
