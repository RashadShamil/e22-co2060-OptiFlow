import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// OptiFlow Design System — "Airbnb-style" premium tokens
/// Every color, radius, shadow and text style lives here.
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Surfaces ────────────────────────────────────────────────────────────────
  static const Color background   = Color(0xFFF7F7F9); // Page background
  static const Color cardSurface  = Color(0xFFFFFFFF); // Floating card
  static const Color bottomSheet  = Color(0xFFFFFFFF);

  // ── Brand ───────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFFFF385C); // Airbnb coral
  static const Color primaryLight = Color(0xFFFF6B85);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF717171);
  static const Color textDisabled  = Color(0xFFAAAAAA);

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color scheduled  = Color(0xFFF5A623); // Warm amber
  static const Color inProgress = Color(0xFF4A90E2); // Cool blue
  static const Color completed  = Color(0xFF2ECC71); // Green
  static const Color offline    = Color(0xFFE74C3C); // Red

  // ── Borders / Dividers ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEBEBEB);
}

class AppTheme {
  AppTheme._();

  static const double radiusCard   = 20.0;
  static const double radiusPill   = 32.0;
  static const double radiusSmall  = 12.0;

  /// The universal card shadow — blur 20, opacity 0.05 black
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  /// Floating card decoration
  static BoxDecoration cardDecoration({double? radius}) => BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(radius ?? radiusCard),
    boxShadow: cardShadow,
  );

  /// Pill-shaped elevated button style (primary coral)
  static ButtonStyle pillButtonStyle({Color? bg, Color? fg}) =>
    ElevatedButton.styleFrom(
      backgroundColor: bg ?? AppColors.primary,
      foregroundColor: fg ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusPill),
      ),
      elevation: 0,
      minimumSize: const Size(double.infinity, 60),
      textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
    );

  /// Full app ThemeData
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textDisabled,
      showUnselectedLabels: false,
      elevation: 0,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Status Badge Widget
// ─────────────────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toUpperCase()) {
      case 'SCHEDULED': return AppColors.scheduled;
      case 'IN_PROGRESS': return AppColors.inProgress;
      case 'COMPLETED': return AppColors.completed;
      case 'OPEN': return AppColors.completed;
      case 'OFFLINE': return AppColors.offline;
      default: return AppColors.textDisabled;
    }
  }

  String get _label => status.replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing Dot indicator for machine status
// ─────────────────────────────────────────────────────────────────────────────
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulsingDot({super.key, required this.color, this.size = 10});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet Drag Handle
// ─────────────────────────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
