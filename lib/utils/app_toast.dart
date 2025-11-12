import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  // 🔹 Standard Toast
  static void show(
      String message, {
        ToastGravity gravity = ToastGravity.BOTTOM,
        Color backgroundColor = Colors.black87,
        Color textColor = Colors.white,
        double fontSize = 16.0,
        Toast? length,
      }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length ?? Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  // 🔹 Erfolg (grün)
  static void success(String message) {
    show(
      message,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
    );
  }

  // 🔹 Fehler (rot)
  static void error(String message) {
    show(
      message,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
    );
  }

  // 🔹 Info (blau)
  static void info(String message) {
    show(
      message,
      backgroundColor: Colors.blue.shade600,
      textColor: Colors.white,
    );
  }

  // 🔹 Warnung (orange)
  static void warning(String message) {
    show(
      message,
      backgroundColor: Colors.orange.shade700,
      textColor: Colors.white,
    );
  }
}
