import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _isDarkModeKey = 'isDarkMode';

  bool _isDarkMode;

  ThemeService(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Retrieve the saved theme (defaults to light mode on first launch)
  static Future<bool> loadIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false;
  }

  // Save the chosen theme so it survives closing the app
  static Future<void> saveIsDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  // Called by the Switch: update the UI, then persist the choice
  Future<void> toggleTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    notifyListeners();
    await saveIsDarkMode(isDarkMode);
  }
}
