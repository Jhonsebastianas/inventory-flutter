import 'package:flutter/material.dart';

class FilterSaleList {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  bool isSelected;

  FilterSaleList({
    required this.label,
    this.icon,
    required this.onTap,
    this.isSelected = false,
  });
}
