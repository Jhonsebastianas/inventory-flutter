import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String? value;
  final String label;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool? enabled;
  final String? hint;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    this.onChanged,
    this.value,
    this.hint,
    this.hintText,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 2, color: Colors.black),
        ),
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: widget.hintText,
      ),
      hint: Text(widget.hint ?? ''),
      items: widget.items,
      onChanged: widget.enabled == true ? widget.onChanged : null,
      validator: widget.validator,
    );
  }
}