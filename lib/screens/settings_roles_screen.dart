// lib/screens/settings_roles_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsRolesScreen extends StatelessWidget {
  const SettingsRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final displayName = firebaseUser?.displayName?.isNotEmpty == true
        ? firebaseUser!.displayName!
        : firebaseUser?.email ?? 'You';
    final role = profile?.role ?? 'owner';

    return ScreenScaffold(
      title: 'Roles & Permissions',
      subtitle: 'Manage access levels for your team.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.accent,
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                              ),
                              child: Text(
                                role[0].toUpperCase() + role.substring(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 48,
                  color: AppColors.muted,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'You are the owner.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Roles & permissions management is coming soon. '
                  'You\'ll be able to assign roles to team members and control what they can access.',
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
