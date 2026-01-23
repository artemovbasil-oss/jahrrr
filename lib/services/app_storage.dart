import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const String appLockKey = 'appLockEnabled';
  static const String themeModeKey = 'theme_mode';
  static const String legacyThemeModeKey = 'themeMode';

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(appLockKey) ?? false;
  }

  static Future<void> setAppLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(appLockKey, value);
  }

  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(themeModeKey);
    if (stored != null) {
      return stored;
    }
    final legacyValue = prefs.getBool(legacyThemeModeKey);
    if (legacyValue == null) {
      return 'system';
    }
    return legacyValue ? 'dark' : 'light';
  }

  static Future<void> setThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, value);
  }
}
