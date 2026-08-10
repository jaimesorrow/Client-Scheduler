// lib/screens/support_help_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SupportHelpScreen extends StatelessWidget {
  const SupportHelpScreen({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'How do I add a client?',
      answer: 'Go to Clients → Add client and fill in the details.',
    ),
    _FaqItem(
      question: 'How do I book an appointment?',
      answer:
          'Go to Appointments → New Appointment and follow the 4-step wizard.',
    ),
    _FaqItem(
      question: 'How do invitations work?',
      answer:
          'Go to Invitations, send an invite link to your client. They can use the link to book without signing up.',
    ),
    _FaqItem(
      question: 'How do I set my availability?',
      answer:
          'Go to Settings → Availability to set your working hours and time off.',
    ),
    _FaqItem(
      question: 'How do I cancel an appointment?',
      answer: 'Open the appointment detail and tap Cancel.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Help & Support',
      subtitle: 'Frequently asked questions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                // FAQ expansion tiles
                ..._faqs.map(
                  (faq) => Column(
                    children: [
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(
                          bottom: AppSpacing.md,
                        ),
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              faq.answer,
                              style: AppTextStyles.bodyMuted,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.divider, height: 1),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Contact link
                GestureDetector(
                  onTap: () => context.go('/support/contact'),
                  child: RichText(
                    text: const TextSpan(
                      style: AppTextStyles.bodyMuted,
                      children: [
                        TextSpan(text: 'Need more help? '),
                        TextSpan(
                          text: 'Contact us',
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
