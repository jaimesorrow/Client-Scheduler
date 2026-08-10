// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // App name
                const Text(
                  'Clientè',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tagline
                const Text(
                  'Premium scheduling for discerning professionals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),

                const Spacer(flex: 2),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth/signin'),
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Create account button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/auth/signup'),
                    child: const Text('Create Account'),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
