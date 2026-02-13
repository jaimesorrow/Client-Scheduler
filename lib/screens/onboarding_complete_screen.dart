import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Onboarding Complete',
      child: const Text(
        'TODO: Implement screen content per spec.',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
