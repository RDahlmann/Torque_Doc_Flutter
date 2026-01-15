import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class AppButtons {
  static Widget primary({
    required String text,
    required VoidCallback onPressed,
    double width = double.infinity,
    double minHeight = 50, // ✅ Mindesthöhe statt fixer Höhe
    double verticalPadding = 8.0,
    IconData? icon,
    Color backgroundColor = AppColors.primary,
    Color foregroundColor = Colors.white,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: SizedBox(
        width: width,
        child: ElevatedButton.icon(
          icon: icon != null
              ? Icon(icon, size: 24)
              : const SizedBox.shrink(),
          label: Text(
            text,
            style: AppTextStyles.button,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 4,
            minimumSize: Size(width, minHeight), // ✅ wächst bei Bedarf
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
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
    double minHeight = 50,
    double verticalPadding = 8.0,
    Color backgroundColor = AppColors.primary,
    Color foregroundColor = Colors.white,
  }) {
    return primary(
      text: text,
      onPressed: onPressed,
      width: width,
      minHeight: minHeight,
      verticalPadding: verticalPadding,
      icon: null,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}
