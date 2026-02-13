import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Welcome',
      child: const Text(
        'TODO: Implement screen content per spec.',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
