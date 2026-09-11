import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _tempUnit = '°C'; // '°C' or '°F'
  String _windUnit = 'km/h'; // 'km/h' or 'mph'
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get tempUnit => _tempUnit;
  String get windUnit => _windUnit;
  bool get notificationsEnabled => _notificationsEnabled;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _tempUnit = prefs.getString('temp_unit') ?? '°C';
    _windUnit = prefs.getString('wind_unit') ?? 'km/h';
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    notifyListeners();
  }

  Future<void> setTempUnit(String unit) async {
    _tempUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_unit', unit);
    notifyListeners();
  }

  Future<void> setWindUnit(String unit) async {
    _windUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wind_unit', unit);
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }
}
