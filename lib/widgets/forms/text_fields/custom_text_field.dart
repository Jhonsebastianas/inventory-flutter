import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType keyboardType;
  final bool? obscureText;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    required this.label,
    this.onSaved,
    this.controller,
    this.hintText,
    this.initialValue,
    this.validator,
    this.obscureText,
    this.focusNode,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText == true && !isPasswordVisible,
      onSaved: widget.onSaved,
      validator: widget.validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 6, color: Colors.black),
        ),
        hintText: widget.hintText,
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(fontSize: 12),
        suffixIcon: widget.obscureText == true
            ? GestureDetector(
                onTap: _togglePasswordVisibility,
                onLongPressStart: (_) =>
                    setState(() => isPasswordVisible = true),
                onLongPressEnd: (_) =>
                    setState(() => isPasswordVisible = false),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: !isPasswordVisible
                      ? const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey,
                          size: 24.0,
                          semanticLabel:
                              'Text to announce in accessibility modes',
                        )
                      : const Icon(
                          Icons.lock_open_rounded,
                          color: Colors.grey,
                          size: 24.0,
                          semanticLabel:
                              'Text to announce in accessibility modes',
                        ),
                  // child: SvgPicture.string(
                  //   isPasswordVisible ? openLockIcon : closedLockIcon,
                  //   color: Colors.grey,
                  // ),
                ),
              )
            : null,
      ),
    );
  }
}