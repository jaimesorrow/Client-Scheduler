// lib/screens/settings_integrations_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsIntegrationsScreen extends StatelessWidget {
  const SettingsIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Integrations',
      subtitle: 'Connect third-party services.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _IntegrationCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Google Calendar',
                  description:
                      'Sync appointments with your Google Calendar automatically.',
                ),
                const SizedBox(height: AppSpacing.md),
                _IntegrationCard(
                  icon: Icons.apple,
                  title: 'Apple Calendar',
                  description:
                      'Keep your Apple Calendar in sync with your schedule.',
                ),
                const SizedBox(height: AppSpacing.md),
                _IntegrationCard(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Processing',
                  description:
                      'Accept payments and deposits directly from clients.',
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

class _IntegrationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _IntegrationCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.muted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: const Text(
                'Coming soon',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
