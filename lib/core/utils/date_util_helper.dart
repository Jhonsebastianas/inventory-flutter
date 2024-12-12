import 'package:intl/intl.dart';

class DateUtilsHelper {
  // Formato estándar para las fechas (ISO 8601)
  static const String standardFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  static const String dateOnlyFormat = "yyyy-MM-dd";
  static const String dateTimeFormat = "yyyy-MM-dd HH:mm:ss";
  static const String yearMonthDayTimeAmPmFormat = "yyyy/MM/dd hh:mm a";

  /// Convierte una fecha local a UTC y devuelve un String formateado
  static String toUtcString(DateTime localDate) {
    final DateTime utcDate = localDate.toUtc();
    return DateFormat(standardFormat).format(utcDate);
  }

  /// Convierte una fecha UTC (String) al formato local de DateTime
  static DateTime fromUtcString(String utcDateString) {
    return DateTime.parse(utcDateString).toLocal();
  }

  /// Obtiene la fecha actual en formato UTC como String
  static String getCurrentUtcString() {
    final DateTime now = DateTime.now().toUtc();
    return DateFormat(standardFormat).format(now);
  }

  /// Convierte una fecha local a un String en el formato deseado
  static String formatDate(DateTime date, {String format = "yyyy-MM-dd HH:mm:ss"}) {
    return DateFormat(format).format(date);
  }

  /// Convierte un String de fecha al formato DateTime local
  static DateTime parseLocalDate(String dateString, {String? format}) {
    if (format != null) {
      final DateFormat dateFormat = DateFormat(format);
      return dateFormat.parse(dateString).toLocal();
    } else {
      return DateTime.parse(dateString).toLocal();
    }
  }

  /// Verifica si una fecha está dentro de un rango
  static bool isWithinRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Agrega días a una fecha
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Resta días a una fecha
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Obtiene el inicio del día para una fecha dada
  static DateTime startOfDay(DateTime date) {
    return date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  }

  /// Obtiene el final del día para una fecha dada
  static DateTime endOfDay(DateTime date) {
    return date.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  }

  /// Extrae solo la parte de la fecha en formato "yyyy-MM-dd"
  static String formatDateOnly(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
