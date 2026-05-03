import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8B5CF6); // Vibrant Purple from logo
  static const Color secondary = Color(0xFFD946EF); // Pink/Magenta from logo
  static const Color accent = Color(0xFF6366F1); // Indigo accent
  
  static const Color background = Color(0xFF0F172A); // Very Deep Blue/Charcoal (Premium Dark)
  static const Color surface = Color(0xFF1E293B); // Slate Surface
  static const Color surfaceLight = Color(0xFF334155); // Lighter Surface for hover states
  
  static const Color textPrimary = Color(0xFFF8FAFC); // Off-White
  static const Color textSecondary = Color(0xFF94A3B8); // Slate Gray
  
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color error = Color(0xFFF43F5E); // Rose Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
