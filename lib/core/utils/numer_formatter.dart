import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class NumberFormatter {
  /// Formatea un número según la configuración regional actual.
  static String format(BuildContext context, double value, {int decimalPlaces = 2}) {
    final locale = Localizations.localeOf(context).toString(); // Obtiene el locale actual
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '', // Sin símbolo de moneda
      decimalDigits: decimalPlaces,
    );
    return formatter.format(value).trim();
  }
}
