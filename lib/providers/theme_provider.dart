import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _selectedColor = const Color(0xFF2563EB); // Default Blue

  Color get selectedColor => _selectedColor;

  static const List<Color> availableColors = [
    Color(0xFFFFAB40), // Orange (Default)
    Color(0xFF2563EB), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFF795548), // Brown
  ];

  void setColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }
}
