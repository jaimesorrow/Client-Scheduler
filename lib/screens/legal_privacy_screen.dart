// lib/screens/legal_privacy_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class LegalPrivacyScreen extends StatelessWidget {
  const LegalPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Privacy Policy',
      subtitle: 'Last updated August 2025.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _PrivacySection(
                    heading: 'What We Collect',
                    body:
                        'We collect your name, email address, and appointment data to provide scheduling services. We may also collect usage information to improve the app.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _PrivacySection(
                    heading: 'How We Use Your Data',
                    body:
                        'Your data is used solely to operate and improve Clientè. We use your name and email to identify your account and send relevant notifications. Appointment data is used to power scheduling features.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _PrivacySection(
                    heading: 'Data Storage',
                    body:
                        'Data is stored securely in Firebase (Google Cloud). Google\'s infrastructure complies with industry-standard security practices including encryption at rest and in transit.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _PrivacySection(
                    heading: 'Data Sharing',
                    body:
                        'We do not sell your data. We do not share your personal information with third parties except as required to operate the service (e.g., Firebase/Google Cloud) or as required by law.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _PrivacySection(
                    heading: 'Your Rights',
                    body:
                        'You may update or delete your account at any time. Deleting your account removes all associated personal data from our systems. Contact us to request a data export.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    '[Full policy at clienteapp.com/privacy]',
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

class _PrivacySection extends StatelessWidget {
  final String heading;
  final String body;

  const _PrivacySection({required this.heading, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: AppTextStyles.body),
      ],
    );
  }
}
