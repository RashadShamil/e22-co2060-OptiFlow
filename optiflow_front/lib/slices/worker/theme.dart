import 'package:flutter/material.dart';
import 'dart:ui';

class MobileTheme {
  static const Color bgColor = Color(0xFF121A2F);
  static const Color surfaceColor = Color(0xFF1E293B);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color emeraldGreen = Color(0xFF00FF9D);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgColor,
    primaryColor: neonBlue,
    fontFamily: 'Roboto', // Default if Google Fonts not used
    useMaterial3: true,
  );
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.05,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
