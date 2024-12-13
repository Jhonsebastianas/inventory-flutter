import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 20),
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
    );
  }

  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }
}
