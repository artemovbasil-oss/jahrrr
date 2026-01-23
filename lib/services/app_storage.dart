import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const String appLockKey = 'appLockEnabled';
  static const String themeModeKey = 'themeMode';

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(appLockKey) ?? false;
  }

  static Future<void> setAppLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(appLockKey, value);
  }

  static Future<bool> isDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeModeKey) ?? false;
  }

  static Future<void> setDarkModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeModeKey, value);
  }
}
