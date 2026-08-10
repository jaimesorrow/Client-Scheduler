// lib/screens/logout_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Sign out of Clientè?',
      subtitle: 'You can sign back in at any time.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              context.go('/auth/signin');
            },
            child: const Text('Sign out'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
