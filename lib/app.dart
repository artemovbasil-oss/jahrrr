import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';

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

class JahrrrApp extends StatelessWidget {
  const JahrrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jahrrr CRM',
      theme: buildJahrrrTheme(),
      home: const AuthGate(),
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
