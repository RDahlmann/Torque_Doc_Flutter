import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class AppButtons {
  static Widget primary({
    required String text,
    required VoidCallback onPressed,
    double width = double.infinity,
    double height = 50,
    double verticalPadding = 8.0, // 👈 neuer Parameter
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding), // Abstand oben & unten
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton.icon(
          icon: icon != null ? Icon(icon, size: 24) : const SizedBox.shrink(),
          label: Text(
            text,
            style: AppTextStyles.button,
          ),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  static Widget primaryText({
    required String text,
    required VoidCallback onPressed,
    double width = double.infinity,
    double height = 50,
    double verticalPadding = 8.0,
  }) {
    return primary(
      text: text,
      onPressed: onPressed,
      width: width,
      height: height,
      verticalPadding: verticalPadding,
      icon: null,
    );
  }
}
