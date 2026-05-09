import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModes { light, dark }

ThemeData _buildTheme(Brightness b, Color scaffold, Color surface) {
  const seed = Color(0xFF3e7f3f);
  final dialogBg = b == Brightness.light ? Colors.white : surface;
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
    dialogTheme: DialogThemeData(
      backgroundColor: dialogBg,
      surfaceTintColor: Colors.transparent,
    ),
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

InputDecoration requiredField(
  BuildContext context, {
  required String label,
  bool hasError = false,
  bool outlined = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? counterText,
  EdgeInsetsGeometry? contentPadding,
}) {
  final scheme = Theme.of(context).colorScheme;
  final errorColor = scheme.error;
  final labelStyle = hasError
      ? TextStyle(color: errorColor, fontWeight: FontWeight.w600)
      : null;
  final floatingLabelStyle = hasError ? TextStyle(color: errorColor) : null;

  if (outlined) {
    final base = scheme.outline;
    final normal = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: base),
    );
    final error = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: errorColor, width: 1.5),
    );
    final border = hasError ? error : normal;
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: counterText,
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      enabledBorder: border,
      focusedBorder: border,
      disabledBorder: border,
      border: border,
    );
  }

  final border = hasError
      ? OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        )
      : const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        );

  return InputDecoration(
    labelText: label,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    counterText: counterText,
    labelStyle: labelStyle,
    floatingLabelStyle: floatingLabelStyle,
    filled: true,
    fillColor: Theme.of(context).scaffoldBackgroundColor,
    enabledBorder: border,
    focusedBorder: border,
    disabledBorder: border,
    border: border,
    contentPadding:
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeModes _mode = ThemeModes.light;
  ThemeModes get themeMode => _mode;

  ThemeData get currentTheme => _themes[_mode.index];

  Future<void> loadTheme() async {
    try {
      final p = await SharedPreferences.getInstance();
      final stored = p.getString('theme_mode');
      _mode = stored == 'dark' ? ThemeModes.dark : ThemeModes.light;
    } catch (_) {
      _mode = ThemeModes.light;
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeModes mode) async {
    _mode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('theme_mode', mode.name);
  }
}
