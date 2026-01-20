class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get supabaseUrlResolved {
    final trimmed = supabaseUrl.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return trimmed;
    }
    return '${uri.scheme}://${uri.host}';
  }

  static String get supabaseAnonKeyResolved => supabaseAnonKey.trim();

  static bool get hasSupabaseConfig =>
      supabaseUrlResolved.isNotEmpty && supabaseAnonKeyResolved.isNotEmpty;

  static bool get hasValidSupabaseUrl {
    if (supabaseUrlResolved.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(supabaseUrlResolved);
    if (uri == null) {
      return false;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'https') {
      return false;
    }
    if (uri.host.isEmpty || !uri.host.endsWith('.supabase.co')) {
      return false;
    }
    return uri.path.isEmpty || uri.path == '/';
  }

  static bool get hasValidSupabaseConfig =>
      hasSupabaseConfig && hasValidSupabaseUrl;

  static String? get supabaseConfigError {
    if (!hasSupabaseConfig) {
      return 'Missing Supabase config. Set SUPABASE_URL and SUPABASE_ANON_KEY.';
    }
    if (!hasValidSupabaseUrl) {
      return 'Invalid SUPABASE_URL. Use https://<project-id>.supabase.co with no extra paths.';
    }
    return null;
  }
}
