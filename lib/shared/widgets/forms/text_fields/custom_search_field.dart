import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextInputAction textInputAction;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  const CustomSearchField({
    Key? key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.textInputAction = TextInputAction.search,
    this.hintStyle,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: textInputAction,
      style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText ?? 'Buscar...',
        hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: onClear ?? () => controller?.clear(),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
