import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomFilterChip({
    Key? key,
    this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reducir padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16), // Bordes más compactos
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 1.2, // Bordes más finos
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                margin: const EdgeInsets.only(right: 6), // Menor separación
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4), // Ícono más compacto
                child: Icon(
                  icon,
                  size: 14, // Reducir tamaño del ícono
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade800 : Colors.black87,
                fontWeight: FontWeight.w500, // Ligero ajuste del peso de la fuente
                fontSize: 12, // Texto más pequeño
              ),
            ),
          ],
        ),
      ),
    );
  }
}
