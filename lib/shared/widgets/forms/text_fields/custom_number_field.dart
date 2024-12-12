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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: allowDecimals
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      onSaved: onSaved,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese un valor.';
            }
            final number =
                allowDecimals ? double.tryParse(value) : int.tryParse(value);
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
