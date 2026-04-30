import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD946EF); // Pinkish
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  
  static const Color background = Color(0xFFF3F4F6); // Light Grey
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF1F2937); // Dark Grey
  static const Color textSecondary = Color(0xFF6B7280); // Light Grey
  
  static const Color success = Color(0xFF22C55E); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFEAB308); // Yellow
  static const Color info = Color(0xFF3B82F6); // Blue

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
