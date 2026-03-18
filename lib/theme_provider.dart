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

ThemeData _appTheme({
  required Brightness brightness,
  required Color scaffoldBackgroundColor,
  required Color surface,
}) {
  return ThemeData(
    brightness: brightness,
    primaryColor: const Color(0xFF3e7f3f),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3e7f3f),
      brightness: brightness,
      surface: surface,
      secondary: const Color(0xFF5AB8B2),
    ),
    useMaterial3: true,
  );
}

final ThemeData lightTheme = _appTheme(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF4F7F5),
  surface: Colors.white,
);

final ThemeData darkNavyTheme = _appTheme(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF12151C),
  surface: const Color(0xFF1E222D),
);

final ThemeData darkAmoledTheme = _appTheme(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  surface: const Color(0xFF121212),
);
