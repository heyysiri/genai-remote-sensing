import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF3F51B5);
  static const Color accentColor = Color(0xFF536DFE);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Button colors
  static const Color buttonColor = Color(0xFF3F51B5);
  static const Color buttonTextColor = Colors.white;

  // Text colors
  static const Color headingColor = Color(0xFF212121);
  static const Color bodyTextColor = Color(0xFF424242);

  // Container decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    foregroundColor: buttonTextColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: headingColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: headingColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: bodyTextColor,
  );
}
