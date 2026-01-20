class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasValidSupabaseUrl {
    if (supabaseUrl.trim().isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(supabaseUrl.trim());
    if (uri == null) {
      return false;
    }
    final scheme = uri.scheme.toLowerCase();
    return (scheme == 'https' || scheme == 'http') && uri.host.isNotEmpty;
  }

  static bool get hasValidSupabaseConfig =>
      hasSupabaseConfig && hasValidSupabaseUrl;

  static String? get supabaseConfigError {
    if (!hasSupabaseConfig) {
      return 'Missing Supabase config. Set SUPABASE_URL and SUPABASE_ANON_KEY.';
    }
    if (!hasValidSupabaseUrl) {
      return 'Invalid SUPABASE_URL. Use a full URL like https://your-project.supabase.co.';
    }
    return null;
  }
}
