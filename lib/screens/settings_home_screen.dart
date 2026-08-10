// lib/screens/settings_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Settings',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsTile(
              icon: Icons.business_outlined,
              title: 'Business Profile',
              onTap: () => context.push('/settings/business-profile'),
            ),
            _SettingsTile(
              icon: Icons.group_outlined,
              title: 'Team',
              onTap: () => context.push('/settings/team'),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push('/settings/notifications'),
            ),
            _SettingsTile(
              icon: Icons.policy_outlined,
              title: 'Policies',
              onTap: () => context.push('/settings/policies'),
            ),
            _SettingsTile(
              icon: Icons.integration_instructions_outlined,
              title: 'Integrations',
              onTap: () => context.push('/settings/integrations'),
            ),
            _SettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Roles & Permissions',
              onTap: () => context.push('/settings/roles'),
            ),
            const Divider(color: AppColors.divider, height: AppSpacing.xxl),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => context.push('/account/change-password'),
            ),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              titleColor: AppColors.danger,
              iconColor: AppColors.danger,
              onTap: () => context.push('/settings/delete-account'),
            ),
            const Divider(color: AppColors.divider, height: AppSpacing.xxl),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                onPressed: () => context.push('/settings/logout'),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.ink),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(color: titleColor),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.muted,
      ),
      onTap: onTap,
    );
  }
}
