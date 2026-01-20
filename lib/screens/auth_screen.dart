import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/app_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthenticated,
    required this.initialProfile,
  });

  final VoidCallback onAuthenticated;
  final UserProfile? initialProfile;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isRegistering = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isRegistering = widget.initialProfile == null;
    if (widget.initialProfile != null) {
      _emailController.text = widget.initialProfile!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      if (_isRegistering) {
        final profile = UserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          updatedAt: DateTime.now(),
        );
        await AppStorage.saveUserProfile(profile);
        await AppStorage.setLoggedIn(true);
        widget.onAuthenticated();
      } else {
        final profile = widget.initialProfile;
        if (profile == null) {
          _showMessage('No account found. Please sign up.');
        } else if (_emailController.text.trim() != profile.email ||
            _passwordController.text.trim() != profile.password) {
          _showMessage('Invalid email or password.');
        } else {
          await AppStorage.setLoggedIn(true);
          widget.onAuthenticated();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jahrrr CRM',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? 'Create your workspace in minutes.'
                        : 'Welcome back. Let\'s pick up where you left off.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ToggleButtons(
                    isSelected: [_isRegistering, !_isRegistering],
                    onPressed: (index) {
                      setState(() {
                        _isRegistering = index == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Text('Sign up'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Text('Sign in'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isRegistering)
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              hintText: 'Alex Johnson',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (!_isRegistering) {
                                return null;
                              }
                              if (value == null || value.trim().length < 2) {
                                return 'Add your name';
                              }
                              return null;
                            },
                          ),
                        if (_isRegistering) const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'you@agency.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null ||
                                !RegExp(r'^.+@.+\..+$').hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'At least 8 characters',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction:
                              _isRegistering ? TextInputAction.next : TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.trim().length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        if (_isRegistering) const SizedBox(height: 16),
                        if (_isRegistering)
                          TextFormField(
                            controller: _confirmController,
                            decoration: const InputDecoration(
                              labelText: 'Confirm password',
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (!_isRegistering) {
                                return null;
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegistering ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isRegistering)
                    Text(
                      'By continuing, you agree to keep your export backup secure.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
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
