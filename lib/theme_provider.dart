import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModes { light, dark }

ThemeData _buildTheme(Brightness b, Color scaffold, Color surface) {
  const seed = Color(0xFF3e7f3f);
  return ThemeData(
    brightness: b,
    primaryColor: seed,
    scaffoldBackgroundColor: scaffold,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: b,
      surface: surface,
      secondary: const Color(0xFF5AB8B2),
    ),
    useMaterial3: true,
  );
}

final _themes = [
  _buildTheme(Brightness.light, const Color(0xFFF4F7F5), Colors.white),
  _buildTheme(
    Brightness.dark,
    const Color(0xFF12151C),
    const Color(0xFF1E222D),
  ),
];

class ThemeProvider extends ChangeNotifier {
  ThemeModes _mode = ThemeModes.light;
  ThemeModes get themeMode => _mode;

  ThemeData get currentTheme => _themes[_mode.index];

  Future<void> loadTheme() async {
    final p = await SharedPreferences.getInstance();
    _mode = _decode(p.getString('theme_mode'));
    notifyListeners();
  }

  Future<void> setTheme(ThemeModes mode) async {
    _mode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('theme_mode', mode.name);
  }
}

ThemeModes _decode(String? raw) {
  return raw == 'dark' ? ThemeModes.dark : ThemeModes.light;
}
