import 'package:flutter/material.dart';

class CustomNumberField extends StatelessWidget {
  final String? initialValue;
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?) onSaved;

  const CustomNumberField({
    Key? key,
    required this.label,
    required this.onSaved,
    this.controller,
    this.hintText,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      onSaved: onSaved,
      validator: validator ?? (value) {
        if (value == null || double.tryParse(value) == null) {
          return 'Por favor ingrese un valor numérico válido.';
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 6, color: Colors.black)),
        hintText: hintText,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
