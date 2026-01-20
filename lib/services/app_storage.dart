import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const String appLockKey = 'appLockEnabled';

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(appLockKey) ?? false;
  }

  static Future<void> setAppLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(appLockKey, value);
  }
}
