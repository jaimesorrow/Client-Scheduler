// lib/screens/onboarding_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 56,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Text(
                      "You're all set!",
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Your workspace is ready.\nLet\'s start booking appointments.',
                      style: AppTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to dashboard'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
