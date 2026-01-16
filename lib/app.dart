import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

class JahrrrApp extends StatelessWidget {
  const JahrrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFF4F3EE);
    const slate = Color(0xFFA7A9AC);
    const charcoal = Color(0xFF1F1C1B);
    const mint = Color(0xFFD6F1DC);
    const sage = Color(0xFF7AA37C);
    const aqua = Color(0xFF3ACFE0);
    const coral = Color(0xFFF47A64);
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
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: cream,
          foregroundColor: charcoal,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0.8,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
