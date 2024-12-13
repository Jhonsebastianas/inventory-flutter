import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class NumberFormatter {
  /// Formatea un número según la configuración regional actual.
  static String format(BuildContext context, double value,
      {int decimalPlaces = 2}) {
    final locale =
        Localizations.localeOf(context).toString(); // Obtiene el locale actual
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '', // Sin símbolo de moneda
      decimalDigits: decimalPlaces,
    );
    return formatter.format(value).trim();
  }

  static double parseDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ??
          0.0; // Maneja errores al convertir cadenas
    }
    if (value is double) {
      return value;
    }
    return 0.0; // Valor predeterminado para casos no manejados
  }
}
