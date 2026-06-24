import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppColors {
  // Base Palette
  static const Color background = Color(0xFF0A0A0C);
  static const Color cardBg = Color(0xFF12121A);
  static const Color cardBorder = Color(0xFF222230);

  // Accents & Gradients
  static const Color primary = Color(0xFF6366F1); // Neon Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Neon Violet

  // Currency-specific colors
  static const Color pkrColor = Color(0xFF10B981); // Emerald Green
  static const Color usdColor = Color(0xFF0EA5E9); // Ocean Blue

  // Financial status
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient pkrGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient usdGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardBg,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
        titleLarge: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
      ),
      // Card theme removed to avoid SDK type mismatches; defaults will be used.
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFFFFFFFF),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.outfit(color: const Color(0xFF0B1220), fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: const Color(0xFF4B5563), fontSize: 14),
        titleLarge: GoogleFonts.outfit(color: const Color(0xFF0B1220), fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: const Color(0xFF0B1220), fontSize: 28, fontWeight: FontWeight.bold),
      ),
      cardColor: const Color(0xFFFFFFFF),
      // Customize other light theme properties as needed
    );
  }
}
