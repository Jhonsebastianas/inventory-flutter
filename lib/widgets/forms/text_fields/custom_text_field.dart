import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? initialValue;
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType keyboardType;
  final bool? obscureText;

  const CustomTextField({
    Key? key,
    required this.label,
    this.onSaved,
    this.controller,
    this.hintText,
    this.initialValue,
    this.validator,
    this.obscureText,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText ?? false,
      onSaved: onSaved,
      validator: validator,
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
