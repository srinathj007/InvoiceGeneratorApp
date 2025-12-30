import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E88E5); // Vibrant Blue
  static const Color secondaryColor = Color(0xFF00C853); // Emerald Green
  static const Color backgroundColor = Color(0xFFF8F9FA); // Off-White
  static const Color surfaceColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withAlpha(8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withAlpha(13)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.black.withAlpha(102), fontSize: 14),
      ),
    );
  }

  static BoxDecoration glassDecoration({double blur = 20, double opacity = 0.7}) {
    return BoxDecoration(
      color: Colors.white.withAlpha((opacity * 255).toInt()),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withAlpha(150)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static List<BoxShadow> get premiumShadows => [
        BoxShadow(
          color: primaryColor.withAlpha(60),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static InputDecoration inputDecoration({required String hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black54) : null,
      filled: true,
      fillColor: Colors.black.withAlpha(8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withAlpha(13)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.black.withAlpha(102), fontSize: 14),
    );
  }

  static void showToast(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;

    final maxWidth = mediaQuery.size.width;
    // Ensure width is at least a small positive value
    final toastWidth = (maxWidth > 600 ? 400.0 : maxWidth * 0.9).clamp(100.0, 400.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isError ? const Color(0xFFEF5350) : const Color(0xFF66BB6A),
        behavior: SnackBarBehavior.floating,
        width: toastWidth,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
