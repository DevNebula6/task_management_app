import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _shortDate = DateFormat('d MMM');
  static final DateFormat _headerDate = DateFormat('d MMM');
  static final DateFormat _time = DateFormat('h:mm a');

  static String formatFull(DateTime date) => _fullDate.format(date);
  static String formatShort(DateTime date) => _shortDate.format(date);
  static String formatTime(DateTime date) => _time.format(date);

  static String formatHeader(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today, ${_headerDate.format(date)}';
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Tomorrow, ${_headerDate.format(date)}';
    }
    return _fullDate.format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final daysDiff = target.difference(today).inDays;
    return daysDiff >= 2 && daysDiff <= 7;
  }

  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isBefore(today);
  }

  static String getSectionName(DateTime date) {
    if (isOverdue(date)) return 'Overdue';
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    if (isThisWeek(date)) return 'This week';
    return 'Later';
  }
}

