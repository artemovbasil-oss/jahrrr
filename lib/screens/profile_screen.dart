import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app.dart';
import '../models/user_profile.dart';
import '../services/supabase_repository.dart';
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
    required this.repository,
  });

  final UserProfile? profile;
  final SupabaseRepository repository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _savingProfile = false;
  bool _exporting = false;
  bool _importing = false;

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
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _savingProfile = true;
    });
    try {
      await widget.repository.updateProfileName(_nameController.text.trim());
      if (!mounted) {
        return;
      }
      _showSnackBar('Profile updated.');
      Navigator.of(context).pop(ProfileResult.updated);
    } on AuthException catch (error) {
      _showSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _savingProfile = false;
        });
      }
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _exporting = true;
    });
    try {
      final data = await widget.repository.exportData();
      final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
      final directory = await getTemporaryDirectory();
      final fileName =
          'jahrrr-backup-${DateTime.now().toIso8601String()}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(prettyJson);
      await Share.shareXFiles([XFile(file.path)], text: 'Jahrrr CRM backup');
      if (mounted) {
        _showSnackBar('Backup exported.');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Export failed.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  Future<void> _importData() async {
    setState(() {
      _importing = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) {
        return;
      }
      final raw = await File(result.files.single.path!).readAsString();
      final mode = await _askImportMode();
      if (mode == null) {
        return;
      }
      await widget.repository.importData(raw, mode: mode);
      if (!mounted) {
        return;
      }
      _showSnackBar('Data imported.');
      Navigator.of(context).pop(ProfileResult.dataImported);
    } catch (_) {
      if (mounted) {
        _showSnackBar('Import failed. Check the JSON format.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
        });
      }
    }
  }

  Future<ImportMode?> _askImportMode() async {
    return showDialog<ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import mode'),
        content: const Text(
          'Choose how to apply the imported data. Replace deletes all existing '
          'rows before importing. Merge upserts by id.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImportMode.merge),
            child: const Text('Merge'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ImportMode.replace),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
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
    final themeController = AppThemeScope.of(context);

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
                      profile?.email ?? '',
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
            'Profile details',
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
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Add your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savingProfile ? null : _saveProfile,
                    child: _savingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: themeController.isDarkMode,
            title: const Text('Dark theme'),
            subtitle: const Text('Toggle between light and dark modes.'),
            onChanged: (value) async {
              await themeController.setDarkMode(value);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Export data'),
            subtitle: const Text('Save and share a JSON backup of your workspace.'),
            trailing: _exporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _exporting ? null : _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Import data'),
            subtitle: const Text('Restore from a previously exported JSON file.'),
            trailing: _importing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _importing ? null : _importData,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _logout,
              child: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}
