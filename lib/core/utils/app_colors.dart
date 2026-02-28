import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7ED421);
  static const Color primaryDark = Color(0xFF5BA318);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFA500);
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color lightBg = Color(0xFFF4F6FA);

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : Colors.white;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[600]!;
  }
}
