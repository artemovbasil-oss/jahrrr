import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_repository.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SupabaseRepository _repository;
  late final StreamSubscription<AuthState> _authSubscription;

  Session? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = SupabaseRepository(Supabase.instance.client);
    _session = Supabase.instance.client.auth.currentSession;
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      _session = data.session;
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    });
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    if (session != null && auth.currentUser == null) {
      try {
        await auth.getUser();
      } catch (_) {
        // auth state will be handled by the listener.
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _session = session;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _handleLoggedOut() {
    Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session != null &&
        Supabase.instance.client.auth.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null) {
      return AuthScreen(
        onAuthenticated: () {},
      );
    }

    return DashboardScreen(
      repository: _repository,
      onLoggedOut: _handleLoggedOut,
    );
  }
}
