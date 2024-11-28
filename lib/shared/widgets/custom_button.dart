import 'package:flutter/material.dart';
import 'package:hola_mundo/core/themes/text_styles.dart';

enum ButtonType { primary, secondary, danger, outline, flat, flatDanger }

class CustomButton extends StatelessWidget {
  final String text;
  final ButtonType type;
  final Icon? icon;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Size? minimumSize;

  const CustomButton({
    Key? key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.icon,
    this.minimumSize,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definición de colores y estilos de acuerdo al tipo de botón
    Color backgroundColor;
    Color textColor;
    BorderSide borderStyle = BorderSide.none;

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
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = Colors.blue;
        borderStyle = BorderSide(color: Colors.blue, width: 2);
        break;
      case ButtonType.flat:
        backgroundColor = Colors.transparent;
        textColor = Colors.blue;
        break;
      case ButtonType.flatDanger:
        backgroundColor = Colors.transparent;
        textColor = Colors.red;
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
          side: borderStyle,
        ),
        elevation: (type == ButtonType.flat || type == ButtonType.outline || type == ButtonType.flatDanger) ? 0 : 2,
        shadowColor: (type == ButtonType.flat || type == ButtonType.outline || type == ButtonType.flatDanger) ? Colors.transparent : null,
        minimumSize: minimumSize,
      ),
      onPressed: isEnabled ? onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8), // Espacio entre el icono y el texto
          ],
          Text(
            text,
            style: TextStyles.buttonText.copyWith(
              color: isEnabled ? textColor : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
