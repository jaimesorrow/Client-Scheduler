// lib/screens/account_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = context.watch<UserProfileProvider>().profile;

    return ScreenScaffold(
      title: 'My Profile',
      subtitle: 'Account details and actions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar / initials circle
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.accent,
              child: Text(
                _initials(user?.displayName),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Display name
          _ProfileRow(
            label: 'Name',
            value: user?.displayName ?? '—',
          ),
          const Divider(color: AppColors.divider, height: AppSpacing.xxl),

          // Email
          _ProfileRow(
            label: 'Email',
            value: user?.email ?? '—',
          ),
          const Divider(color: AppColors.divider, height: AppSpacing.xxl),

          // Role
          _ProfileRow(
            label: 'Role',
            value: _formatRole(profile?.role),
          ),

          const Spacer(),

          // Action buttons
          OutlinedButton(
            onPressed: () => context.go('/account/change-password'),
            child: const Text('Change Password'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.go('/account/delete'),
            child: const Text('Delete Account'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              context.go('/auth/signin');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatRole(String? role) {
    if (role == null) return '—';
    return role[0].toUpperCase() + role.substring(1);
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: AppTextStyles.bodyMuted),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(value, style: AppTextStyles.body),
        ),
      ],
    );
  }
}
