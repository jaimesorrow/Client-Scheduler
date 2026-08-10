// lib/screens/legal_data_safety_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class LegalDataSafetyScreen extends StatelessWidget {
  const LegalDataSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Data Safety',
      subtitle: 'How your information is handled.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DataSafetyRow(
                    icon: Icons.person_outline,
                    label: 'Name & Email',
                    detail:
                        'Collected to identify your account and send scheduling notifications.',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.xxl),
                  _DataSafetyRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Appointment details',
                    detail:
                        'Client names, services, and appointment times are stored to power your scheduling.',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.xxl),
                  _DataSafetyRow(
                    icon: Icons.storage_outlined,
                    label: 'Storage',
                    detail:
                        'All data is stored on Firebase / Google Cloud infrastructure with encryption at rest and in transit.',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.xxl),
                  _DataSafetyRow(
                    icon: Icons.shield_outlined,
                    label: 'Security',
                    detail:
                        'Access to your data is protected by Firebase Authentication. Only you and users you authorize can see your business data.',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.xxl),
                  _DataSafetyRow(
                    icon: Icons.delete_outline,
                    label: 'Your right to delete',
                    detail:
                        'Deleting your account via Settings → Account → Delete Account permanently removes all your personal and business data from our systems.',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.xxl),
                  _DataSafetyRow(
                    icon: Icons.share_outlined,
                    label: 'Data sharing',
                    detail:
                        'We never sell your data. Data is shared only with Google (Firebase) as the underlying infrastructure provider.',
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text(
                    'Questions about your data?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Contact us at privacy@clienteapp.com',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () {
              if (context.canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/settings');
              }
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class _DataSafetyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;

  const _DataSafetyRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(detail, style: AppTextStyles.bodyMuted),
            ],
          ),
        ),
      ],
    );
  }
}
