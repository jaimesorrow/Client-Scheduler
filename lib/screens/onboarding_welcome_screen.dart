import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/auth/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Welcome to Clientè',
      subtitle: 'Let’s set up your business in 2 minutes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Business', style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          const Text('2. Availability', style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          const Text('3. Finish', style: AppTextStyles.body),
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.go('/onboarding/business'),
            child: const Text('Start setup'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => _signOut(context),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
