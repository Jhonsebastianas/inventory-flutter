import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final ButtonType type;
  final VoidCallback onPressed;
  final bool isEnabled;

  const CustomButton({
    Key? key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilos según el tipo de botón
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.grey.shade600;
        textColor = Colors.white;
        break;
      case ButtonType.danger:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? backgroundColor : Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: isEnabled ? onPressed : null,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
