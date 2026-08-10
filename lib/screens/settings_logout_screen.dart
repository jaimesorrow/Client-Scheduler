// lib/screens/settings_logout_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsLogoutScreen extends StatefulWidget {
  const SettingsLogoutScreen({super.key});

  @override
  State<SettingsLogoutScreen> createState() => _SettingsLogoutScreenState();
}

class _SettingsLogoutScreenState extends State<SettingsLogoutScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.go('/auth/signin');
    } catch (e) {
      setState(() => _error = 'Unable to log out. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Log Out',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout,
                    size: 64,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Are you sure you want to log out?',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'You can sign back in at any time.',
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
            ),
            onPressed: _isLoading ? null : _logout,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : const Text('Log out'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
