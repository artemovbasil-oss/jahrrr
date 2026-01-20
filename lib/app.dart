import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';

class JahrrrApp extends StatelessWidget {
  const JahrrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFF6F4F0);
    const slate = Color(0xFF8D9BA7);
    const charcoal = Color(0xFF101828);
    const mint = Color(0xFFE8F4EC);
    const sage = Color(0xFF1FA85B);
    const aqua = Color(0xFF2D6EF8);
    const coral = Color(0xFFF9D4B0);
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jahrrr CRM',
      theme: ThemeData(
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
      ),
      home: const AuthGate(),
    );
  }
}
