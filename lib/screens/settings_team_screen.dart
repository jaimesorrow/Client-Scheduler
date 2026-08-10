// lib/screens/settings_team_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsTeamScreen extends StatelessWidget {
  const SettingsTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Team',
      subtitle: 'Manage your team members.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Team management coming soon.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'You\'ll be able to invite and manage team members here.',
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
