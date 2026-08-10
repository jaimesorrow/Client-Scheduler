// lib/screens/legal_terms_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class LegalTermsScreen extends StatelessWidget {
  const LegalTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Terms of Service',
      subtitle: 'Last updated August 2025.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TermsSection(
                    heading: 'Agreement',
                    body:
                        'By using Clientè, you agree to these terms. This app is provided as-is for scheduling purposes. Do not use this app for any unlawful activities.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _TermsSection(
                    heading: 'Use of Service',
                    body:
                        'You may use Clientè to manage your client appointments and scheduling. You are responsible for maintaining the accuracy of the information you enter. You must not use this service to harass, harm, or deceive others.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _TermsSection(
                    heading: 'Account Responsibility',
                    body:
                        'You are responsible for safeguarding your account credentials. Notify us promptly if you suspect unauthorized access. Anthropic/Clientè is not liable for any loss arising from unauthorized account use.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _TermsSection(
                    heading: 'Termination',
                    body:
                        'We reserve the right to suspend or terminate accounts that violate these terms. You may delete your account at any time via account settings.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  _TermsSection(
                    heading: 'Limitation of Liability',
                    body:
                        'The app is provided "as-is" without warranty of any kind. We are not responsible for scheduling errors, data loss, or any indirect damages arising from use of the service.',
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    '[Full terms available at clienteapp.com/terms]',
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

class _TermsSection extends StatelessWidget {
  final String heading;
  final String body;

  const _TermsSection({required this.heading, required this.body});

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
