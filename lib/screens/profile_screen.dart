import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../services/app_storage.dart';
import '../widgets/user_avatar.dart';

enum ProfileResult {
  none,
  updated,
  dataImported,
  loggedOut,
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
  });

  final UserProfile? profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _savingProfile = true;
    });
    final existingPassword = widget.profile?.password ?? '';
    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: existingPassword,
      updatedAt: DateTime.now(),
    );
    await AppStorage.saveUserProfile(profile);
    if (!mounted) {
      return;
    }
    setState(() {
      _savingProfile = false;
    });
    _showSnackBar('Profile updated.');
    Navigator.of(context).pop(ProfileResult.updated);
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _savingPassword = true;
    });
    final profile = widget.profile;
    if (profile == null) {
      _showSnackBar('Create an account first.');
    } else if (_currentPasswordController.text.trim() != profile.password) {
      _showSnackBar('Current password is incorrect.');
    } else {
      final updated = UserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _newPasswordController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await AppStorage.saveUserProfile(updated);
      if (!mounted) {
        return;
      }
      _showSnackBar('Password updated.');
      Navigator.of(context).pop(ProfileResult.updated);
    }
    if (mounted) {
      setState(() {
        _savingPassword = false;
      });
    }
  }

  Future<void> _exportData() async {
    final data = await AppStorage.exportData();
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export backup'),
        content: SingleChildScrollView(
          child: SelectableText(prettyJson),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: prettyJson));
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              if (mounted) {
                _showSnackBar('Export copied to clipboard.');
              }
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import backup'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Paste the exported JSON here',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      await AppStorage.importData(result.trim());
      if (!mounted) {
        return;
      }
      _showSnackBar('Data imported.');
      Navigator.of(context).pop(ProfileResult.dataImported);
    } catch (_) {
      if (mounted) {
        _showSnackBar('Import failed. Check the JSON format.');
      }
    }
  }

  Future<void> _logout() async {
    await AppStorage.setLoggedIn(false);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(ProfileResult.loggedOut);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final displayName = profile?.displayName ?? 'Your profile';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              UserAvatar(
                name: profile?.name,
                email: profile?.email,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? 'No email set',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Account details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _profileFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Enter at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^.+@.+\..+$').hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savingProfile ? null : _saveProfile,
                    child: _savingProfile
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Change password',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _passwordFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(labelText: 'Current password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'New password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _savingPassword ? null : _changePassword,
                    child: _savingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update password'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Data management',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Export all data'),
                      ),
                      TextButton(
                        onPressed: _exportData,
                        child: const Text('Export'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.upload),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Import backup'),
                      ),
                      TextButton(
                        onPressed: _importData,
                        child: const Text('Import'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Session',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
