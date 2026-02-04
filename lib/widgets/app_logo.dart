import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showName;
  final Color? color;
  final double fontSize;

  const AppLogo({
    super.key, 
    this.size = 64, 
    this.showName = true,
    this.color,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (showName) {
      return Image.asset(
        'assets/logo_with_name.png',
        height: size + (fontSize * 1.5),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 12),
            Text(
              'ManaBill',
              style: GoogleFonts.outfit(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
    return _buildIcon();
  }

  Widget _buildIcon() {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF1E293B),
          child: const Icon(Icons.error_outline, color: Colors.white),
        ),
      ),
    );
  }
}
