import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final rawUrl = AppConfig.supabaseUrl;
  final resolvedUrl = AppConfig.supabaseUrlResolved;
  final resolvedAnonKey = AppConfig.supabaseAnonKeyResolved;
  debugPrint('SUPABASE_URL resolved: $resolvedUrl');
  debugPrint('SUPABASE_ANON_KEY length: ${resolvedAnonKey.length}');
  if (rawUrl.trim() != resolvedUrl) {
    debugPrint('SUPABASE_URL normalized from "$rawUrl" to "$resolvedUrl"');
  }
  if (rawUrl.contains('/auth')) {
    debugPrint('SUPABASE_URL contained /auth path; using base project URL instead.');
  }
  assert(resolvedUrl.startsWith('https://'), 'SUPABASE_URL must start with https://');
  assert(!resolvedUrl.contains('/auth'), 'SUPABASE_URL must not include /auth paths.');
  final configError = AppConfig.supabaseConfigError;
  if (configError != null) {
    runApp(ConfigErrorApp(message: configError));
    return;
  }
  await Supabase.initialize(
    url: resolvedUrl,
    anonKey: resolvedAnonKey,
  );
  final themeController = AppThemeController(ThemeMode.system);
  await themeController.load();
  runApp(JahrrrApp(themeController: themeController));
}
