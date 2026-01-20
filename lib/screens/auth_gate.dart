import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/app_storage.dart';
import '../services/supabase_repository.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  late final SupabaseRepository _repository;
  late final StreamSubscription<AuthState> _authSubscription;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Session? _session;
  bool _isLoading = true;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        if (_session == null) {
          _isLocked = false;
        }
      });
      await _maybeRequireUnlock(force: true);
    });
    _loadInitialLockState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeRequireUnlock(force: true);
    }
  }

  Future<void> _loadInitialLockState() async {
    await _maybeRequireUnlock(force: true);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _maybeRequireUnlock({bool force = false}) async {
    if (_session == null) {
      return;
    }
    final enabled = await AppStorage.isAppLockEnabled();
    if (!enabled) {
      if (mounted) {
        setState(() {
          _isLocked = false;
        });
      }
      return;
    }
    if (!force && !_isLocked) {
      return;
    }
    if (mounted) {
      setState(() {
        _isLocked = true;
      });
    }
    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Unlock Jahrrr CRM',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isLocked = !didAuthenticate;
    });
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

    if (_session == null) {
      return AuthScreen(
        onAuthenticated: () {},
      );
    }

    if (_isLocked) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'App locked',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unlock with biometrics or device passcode.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _maybeRequireUnlock(force: true),
                  child: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DashboardScreen(
      repository: _repository,
      onLoggedOut: _handleLoggedOut,
    );
  }
}
