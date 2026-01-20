import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(
    AppConfig.supabaseUrl.isNotEmpty && AppConfig.supabaseAnonKey.isNotEmpty,
    'Missing Supabase configuration. Use --dart-define for SUPABASE_URL and SUPABASE_ANON_KEY.',
  );
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const JahrrrApp());
}
