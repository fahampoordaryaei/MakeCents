import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, darkNavy, darkAmoled }

class ThemeProvider extends ChangeNotifier {
  ThemeType _themeType = ThemeType.light;

  ThemeType get themeType => _themeType;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_pref_v2') ?? 'ThemeType.light';
    _themeType = ThemeType.values.firstWhere(
      (e) => e.toString() == savedTheme,
      orElse: () => ThemeType.light,
    );
    notifyListeners();
  }

  Future<void> setTheme(ThemeType type) async {
    _themeType = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_pref_v2', type.toString());
  }

  ThemeData get currentTheme {
    switch (_themeType) {
      case ThemeType.darkNavy:
        return darkNavyTheme;
      case ThemeType.darkAmoled:
        return darkAmoledTheme;
      case ThemeType.light:
        return lightTheme;
    }
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF3e7f3f),
  scaffoldBackgroundColor: const Color(0xFFF4F7F5),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3e7f3f),
    secondary: Color(0xFF4ECDC4),
    surface: Colors.white,
  ),
  useMaterial3: true,
);

final ThemeData darkNavyTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF3e7f3f),
  scaffoldBackgroundColor: const Color(0xFF12151C),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3e7f3f),
    secondary: Color(0xFF4ECDC4),
    surface: Color(0xFF1E222D),
  ),
  useMaterial3: true,
);

final ThemeData darkAmoledTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF3e7f3f),
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3e7f3f),
    secondary: Color(0xFF4ECDC4),
    surface: Color(0xFF121212),
  ),
  useMaterial3: true,
);
