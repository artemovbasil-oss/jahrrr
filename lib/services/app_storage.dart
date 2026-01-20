import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AppStorage {
  static const String clientsKey = 'clients';
  static const String projectsKey = 'projects';
  static const String projectPaymentsKey = 'projectPayments';
  static const String legacyPaymentsKey = 'payments';
  static const String userProfileKey = 'userProfile';
  static const String authKey = 'isLoggedIn';
  static const int schemaVersion = 1;

  static Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(userProfileKey);
    if (raw == null) {
      return null;
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userProfileKey, jsonEncode(profile.toJson()));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(authKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(authKey, value);
  }

  static Future<Map<String, dynamic>> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final clients = _decodeList(prefs.getString(clientsKey));
    final projects = _decodeList(prefs.getString(projectsKey));
    final payments = _decodeList(prefs.getString(projectPaymentsKey));
    final legacyPayments = _decodeList(prefs.getString(legacyPaymentsKey));
    final profileRaw = prefs.getString(userProfileKey);
    Map<String, dynamic>? profile;
    if (profileRaw != null) {
      try {
        profile = jsonDecode(profileRaw) as Map<String, dynamic>;
      } catch (_) {
        profile = null;
      }
    }

    return {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'userProfile': profile,
      'clients': clients,
      'projects': projects,
      'projectPayments': payments.isNotEmpty ? payments : legacyPayments,
    };
  }

  static Future<void> importData(String payload) async {
    final prefs = await SharedPreferences.getInstance();
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final clients = decoded['clients'];
    final projects = decoded['projects'];
    final payments = decoded['projectPayments'] ?? decoded['payments'];
    final profile = decoded['userProfile'];

    if (clients is List<dynamic>) {
      await prefs.setString(clientsKey, jsonEncode(clients));
    }
    if (projects is List<dynamic>) {
      await prefs.setString(projectsKey, jsonEncode(projects));
    }
    if (payments is List<dynamic>) {
      await prefs.setString(projectPaymentsKey, jsonEncode(payments));
    }
    if (profile is Map<String, dynamic>) {
      await prefs.setString(userProfileKey, jsonEncode(profile));
      await prefs.setBool(authKey, true);
    }
  }

  static List<dynamic> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
