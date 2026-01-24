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

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Inter',
  );

  return baseTheme.copyWith(
    scaffoldBackgroundColor: cream,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: cream,
      foregroundColor: charcoal,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.04),
      surfaceTintColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.7),
      selectedColor: colorScheme.primary.withOpacity(0.12),
      labelStyle: baseTheme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.25)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      modalBackgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      dragHandleColor: colorScheme.surfaceVariant,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withOpacity(0.3),
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
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

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: midnight,
    fontFamily: 'Inter',
  );

  return baseTheme.copyWith(
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: midnight,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.6),
      surfaceTintColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.85),
      selectedColor: colorScheme.primary.withOpacity(0.22),
      labelStyle: baseTheme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      side: BorderSide(color: colorScheme.outline.withOpacity(0.6)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      modalBackgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      dragHandleColor: colorScheme.outline.withOpacity(0.6),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withOpacity(0.6),
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
  );
}

class AppThemeController extends ChangeNotifier {
  AppThemeController(this._mode);

  ThemeMode _mode;

  ThemeMode get themeMode => _mode;

  Future<void> load() async {
    final storedMode = await AppStorage.getThemeMode();
    _mode = switch (storedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    debugPrint('Theme mode updated: $_mode');
    notifyListeners();
    await AppStorage.setThemeMode(_mode.name);
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

class JahrrrApp extends StatelessWidget {
  const JahrrrApp({
    super.key,
    required AppThemeController themeController,
  }) : _themeController = themeController;

  final AppThemeController _themeController;

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
            themeMode: _themeController.themeMode,
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
