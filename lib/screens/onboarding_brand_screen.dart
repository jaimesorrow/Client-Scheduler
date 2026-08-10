// lib/screens/onboarding_brand_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class OnboardingBrandScreen extends StatefulWidget {
  const OnboardingBrandScreen({super.key});

  @override
  State<OnboardingBrandScreen> createState() => _OnboardingBrandScreenState();
}

class _OnboardingBrandScreenState extends State<OnboardingBrandScreen> {
  final _taglineController = TextEditingController();

  @override
  void dispose() {
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Brand setup',
      subtitle: 'Add a tagline that clients see when they book with you.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _taglineController,
            decoration: const InputDecoration(
              labelText: 'Tagline (optional)',
              hintText: 'e.g. "Expert care, every visit"',
            ),
            maxLength: 120,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'You can always update this later in your business profile.',
            style: AppTextStyles.bodyMuted,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.go('/onboarding/hours'),
            child: const Text('Continue'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.go('/onboarding/hours'),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
