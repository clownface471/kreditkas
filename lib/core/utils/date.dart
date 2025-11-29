import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormatter = DateFormat('HH:mm:ss');
  static final DateFormat _dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _displayDateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayDateTimeFormatter = DateFormat('MMM dd, yyyy HH:mm');

  /// Format date as yyyy-MM-dd
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format time as HH:mm:ss
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Format date and time as yyyy-MM-dd HH:mm:ss
  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  /// Format date for display (MMM dd, yyyy)
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormatter.format(date);
  }

  /// Format date and time for display (MMM dd, yyyy HH:mm)
  static String formatDisplayDateTime(DateTime date) {
    return _displayDateTimeFormatter.format(date);
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return startOfDay(monday);
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return endOfDay(sunday);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return endOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Get number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return to.difference(from).inDays;
  }

  /// Add months to a date
  static DateTime addMonths(DateTime date, int months) {
    int newMonth = date.month + months;
    int newYear = date.year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear += 1;
    }

    while (newMonth < 1) {
      newMonth += 12;
      newYear -= 1;
    }

    int newDay = date.day;
    final daysInMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > daysInMonth) {
      newDay = daysInMonth;
    }

    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}
