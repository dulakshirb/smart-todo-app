import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(String time) {
    return DateFormat('HH:mm').format(DateFormat('HH:mm').parse(time));
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static bool isOverdue(DateTime dueDate, String dueTime) {
    final now = DateTime.now();
    final due = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      int.parse(dueTime.split(':')[0]),
      int.parse(dueTime.split(':')[1]),
    );
    return now.isAfter(due);
  }

  static DateTime combineDateAndTime(DateTime date, String timeString) {
    final timeParts = timeString.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }
}
