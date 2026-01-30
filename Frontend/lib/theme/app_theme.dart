import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFC8E6C9);

  // Neutral Colors
  static const Color darkText = Color(0xFF212121);
  static const Color lightText = Color(0xFF757575);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  // Status Colors
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFB8C00);

  // Text Styles
  static TextStyle headlineLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: darkText,
  );

  static TextStyle headlineMedium = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkText,
  );

  static TextStyle headlineSmall = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkText,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: darkText,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: lightText,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: lightText,
  );

  static TextStyle buttonText = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle labelSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: lightText,
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    side: const BorderSide(color: primaryGreen, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: primaryGreen)
          : null,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: lightText),
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Card Style
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Elevated Card Style
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
