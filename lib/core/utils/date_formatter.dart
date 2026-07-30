import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String toDisplay(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String toDisplayWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(date);
  }

  static String toTimeOnly(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  static String toDbFormat(DateTime date) {
    return date.toIso8601String();
  }

  static String toDateOnly(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime fromDb(String value) {
    return DateTime.parse(value);
  }
}