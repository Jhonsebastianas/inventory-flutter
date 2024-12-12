import 'package:flutter/material.dart';

class CustomNumberField extends StatelessWidget {
  final String? initialValue;
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool allowDecimals; // Nueva propiedad para permitir decimales

  const CustomNumberField({
    Key? key,
    required this.label,
    this.onSaved,
    this.controller,
    this.hintText,
    this.initialValue,
    this.validator,
    this.allowDecimals = false, // Valor por defecto
  }) : super(key: key);

  String _normalizeDecimalInput(String input) {
    // Detecta el separador decimal del sistema
    final decimalSeparator = RegExp(r'[.,]').firstMatch('1.1')?.group(0) ?? '.';

    // Reemplaza el separador incorrecto
    if (decimalSeparator == ',') {
      return input.replaceAll('.', ',');
    } else {
      return input.replaceAll(',', '.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: allowDecimals
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      onChanged: (value) {
        if (allowDecimals) {
          final normalizedValue = _normalizeDecimalInput(value);
          controller?.text = normalizedValue;
          controller?.selection = TextSelection.fromPosition(
            TextPosition(offset: normalizedValue.length),
          );
        }
      },
      onSaved: onSaved,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese un valor.';
            }
            final normalizedValue = _normalizeDecimalInput(value);
            final number = allowDecimals
                ? double.tryParse(normalizedValue)
                : int.tryParse(value);
            if (number == null) {
              return 'Por favor ingrese un valor ${allowDecimals ? "numérico válido" : "entero válido"}.';
            }
            return null;
          },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 6, color: Colors.black),
        ),
        hintText: hintText,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
