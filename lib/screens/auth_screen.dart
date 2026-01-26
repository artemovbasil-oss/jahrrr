import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/app_config.dart';
import '../utils/app_snack.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isSending = false;
  bool _isVerifying = false;
  bool _otpSent = false;
  String? _lastSubmittedOtp;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final configError = AppConfig.supabaseConfigError;
    if (configError != null) {
      _showError(configError);
      return;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Invalid email format.');
      return;
    }
    setState(() {
      _isSending = true;
    });
    try {
      final settingsOk = await _probeSupabaseSettings();
      if (!settingsOk) {
        return;
      }
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
      );
      if (mounted) {
        setState(() {
          _otpSent = true;
        });
        _focusOtpField();
      }
      AppSnack.showSuccess(context, 'OTP sent to your email.');
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(_friendlyNetworkMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) {
      return;
    }
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _showError('Enter the 6-digit code.');
      return;
    }
    final configError = AppConfig.supabaseConfigError;
    if (configError != null) {
      _showError(configError);
      return;
    }
    setState(() {
      _isVerifying = true;
    });
    _lastSubmittedOtp = code;
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: _emailController.text.trim(),
        token: code,
        type: OtpType.email,
      );
      final name = _nameController.text.trim();
      if (response.user != null && name.isNotEmpty) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'name': name}),
        );
      }
      widget.onAuthenticated();
    } on AuthException catch (error) {
      _showError(error.message);
      _lastSubmittedOtp = null;
    } catch (error) {
      _showError(_friendlyNetworkMessage(error));
      _lastSubmittedOtp = null;
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    AppSnack.showError(context, message);
  }

  Future<bool> _probeSupabaseSettings() async {
    final baseUrl = AppConfig.supabaseUrlResolved;
    if (baseUrl.isEmpty) {
      _showError('SUPABASE_URL is missing.');
      return false;
    }
    final settingsUri = Uri.parse('$baseUrl/auth/v1/settings');
    debugPrint('Supabase settings probe: $settingsUri');
    final client = HttpClient();
    try {
      final request = await client.getUrl(settingsUri);
      request.headers.set('apikey', AppConfig.supabaseAnonKeyResolved);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      debugPrint('Supabase settings response: ${response.statusCode} $body');
      if (response.statusCode >= 400) {
        _showError(
          'Supabase settings check failed (${response.statusCode}). Check SUPABASE_URL.',
        );
        return false;
      }
      return true;
    } catch (error) {
      debugPrint('Supabase settings probe failed: $error');
      _showError(_friendlyNetworkMessage(error));
      return false;
    } finally {
      client.close(force: true);
    }
  }

  String _friendlyNetworkMessage(Object error) {
    final message = error.toString();
    if (message.contains('Failed host lookup') ||
        message.contains('SocketException')) {
      return 'Unable to reach Supabase. Check your network or SUPABASE_URL.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _focusOtpField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_otpSent) {
        return;
      }
      _otpFocusNode.requestFocus();
    });
  }

  void _handleOtpChanged(String value) {
    if (_isVerifying) {
      return;
    }
    if (value.length < 6) {
      _lastSubmittedOtp = null;
      return;
    }
    if (value.length == 6 && value != _lastSubmittedOtp) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isSending || _isVerifying;
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
                    'Sign in or create your workspace using email OTP.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full name (optional)',
                            hintText: 'Alex Johnson',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
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
                        if (_otpSent)
                          TextFormField(
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            autofocus: _otpSent,
                            decoration: InputDecoration(
                              labelText: '6-digit code',
                              suffixIcon: _isVerifying
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !_isVerifying,
                            textInputAction: TextInputAction.done,
                            inputFormatters: const [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: _handleOtpChanged,
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : _otpSent
                                    ? _verifyOtp
                                    : _sendOtp,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(_otpSent ? 'Verify code' : 'Send code'),
                          ),
                        ),
                        if (_otpSent) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: isLoading ? null : _sendOtp,
                            child: const Text('Resend code'),
                          ),
                        ],
                      ],
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
