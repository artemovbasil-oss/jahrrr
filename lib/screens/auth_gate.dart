import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/app_storage.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final profile = await AppStorage.loadUserProfile();
    final loggedIn = await AppStorage.isLoggedIn();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = profile;
      _isAuthenticated = loggedIn && profile != null;
      _isLoading = false;
    });
  }

  Future<void> _handleAuthenticated() async {
    final profile = await AppStorage.loadUserProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = profile;
      _isAuthenticated = true;
    });
  }

  Future<void> _handleLoggedOut() async {
    await AppStorage.setLoggedIn(false);
    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return AuthScreen(
        onAuthenticated: _handleAuthenticated,
        initialProfile: _profile,
      );
    }

    return DashboardScreen(
      onLoggedOut: _handleLoggedOut,
    );
  }
}
