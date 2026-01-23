import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'services/app_storage.dart';

ThemeData buildJahrrrTheme() {
  const cream = Color(0xFFF6F4F0);
  const slate = Color(0xFF8D9BA7);
  const charcoal = Color(0xFF101828);
  const mint = Color(0xFFE8F4EC);
  const sage = Color(0xFF1FA85B);
  const aqua = Color(0xFF2D6EF8);
  const brick = Color(0xFFB8432D);

  final colorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: aqua,
    onPrimary: Colors.white,
    secondary: sage,
    onSecondary: Colors.white,
    error: brick,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: charcoal,
    surfaceVariant: mint,
    onSurfaceVariant: charcoal,
    outline: slate,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: cream,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: cream,
      foregroundColor: charcoal,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
  );
}

ThemeData buildJahrrrDarkTheme() {
  const midnight = Color(0xFF0B0F1A);
  const slate = Color(0xFF8D9BA7);
  const mint = Color(0xFF1E2A24);
  const sage = Color(0xFF35C76A);
  const aqua = Color(0xFF4C7DFF);
  const brick = Color(0xFFE06B52);

  final colorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: aqua,
    onPrimary: Colors.white,
    secondary: sage,
    onSecondary: Colors.white,
    error: brick,
    onError: Colors.white,
    surface: Color(0xFF141A28),
    onSurface: Colors.white,
    surfaceVariant: mint,
    onSurfaceVariant: slate,
    outline: Color(0xFF3C4757),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: midnight,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: midnight,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF141A28),
      elevation: 0,
      surfaceTintColor: Color(0xFF141A28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
  );
}

class AppThemeController extends ChangeNotifier {
  AppThemeController(this._mode);

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  Future<void> load() async {
    final isDark = await AppStorage.isDarkModeEnabled();
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await AppStorage.setDarkModeEnabled(value);
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('AppThemeScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}

class JahrrrApp extends StatefulWidget {
  const JahrrrApp({super.key});

  @override
  State<JahrrrApp> createState() => _JahrrrAppState();
}

class _JahrrrAppState extends State<JahrrrApp> {
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController(ThemeMode.light);
    _themeController.load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Jahrrr CRM',
            theme: buildJahrrrTheme(),
            darkTheme: buildJahrrrDarkTheme(),
            themeMode: _themeController.mode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jahrrr CRM',
      theme: buildJahrrrTheme(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Configuration required',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Provide a valid Supabase project URL and anon key, then restart the app.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
