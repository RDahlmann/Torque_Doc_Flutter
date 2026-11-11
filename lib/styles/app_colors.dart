import 'package:flutter/material.dart';

enum Customer {
  Standart,
  Alkitronik,
}

class AppColors {
  // ============================================================
  // KUNDENAUSWAHL
  // ============================================================

  static const Customer activeCustomer = Customer.Standart;

  // ============================================================
  // PRIMÄRFARBEN
  // ============================================================

  // Standard
  static const Color primaryStandard = Color(0xFF0057B7);

  // Alkitronik
  static const Color primaryAlkitronik = Color(0xFFE10613);

  // Aktive Primärfarbe entsprechend dem Kunden
  static const Color primary = activeCustomer == Customer.Alkitronik
      ? primaryAlkitronik
      : primaryStandard;

  // ============================================================
  // SEKUNDÄR- UND AKZENTFARBEN
  // ============================================================

  static const Color secondary = Color(0xFF009DFF);
  static const Color accent = Color(0xFF00BFA5);

  // ============================================================
  // ANMATECH / BLUETOOTH-DESIGN
  // ============================================================

  // Dunkelblauer Farbverlauf im Kopfbereich
  static const Color darkBlue = Color(0xFF12345A);
  static const Color blue = Color(0xFF1769AA);

  // Helle Blautöne
  static const Color lightBlue = Color(0xFFEAF3FC);
  static const Color veryLightBlue = Color(0xFFF2F7FC);

  // ============================================================
  // HINTERGRÜNDE
  // ============================================================

  static const Color background = Color(0xFFF2F5F9);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundInput = Color(0xFFF8FAFD);

  // ============================================================
  // TEXTFARBEN
  // ============================================================

  static const Color text = Color(0xFF333333);
  static const Color textPrimary = Color(0xFF12345A);
  static const Color textSecondary = Color(0xFF68778D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF8A98AA);

  // ============================================================
  // RAHMEN UND TRENNLINIEN
  // ============================================================

  static const Color border = Color(0xFFE1E8F0);
  static const Color divider = Color(0xFFE6EBF2);

  // ============================================================
  // STATUSFARBEN
  // ============================================================

  static const Color green = Color(0xFF2B6801);
  static const Color success = Color(0xFF20A464);

  static const Color warning = Color(0xFFE59B27);
  static const Color error = Color(0xFFB42318);
  static const Color red = Color(0xFF6A1111);
  static const Color darkblue = Color(0xFF013595);
  static const Color info = Color(0xFF1769AA);

  // ============================================================
  // ALLGEMEINE FARBEN
  // ============================================================

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // ============================================================
  // DEZENTE FLÄCHEN UND SCHATTEN
  // ============================================================

  static const Color shadow = Color(0x1212345A);

  static const Color successBackground = Color(0x1220A464);
  static const Color warningBackground = Color(0x12E59B27);
  static const Color errorBackground = Color(0x12B42318);
  static const Color infoBackground = Color(0x121769AA);
}