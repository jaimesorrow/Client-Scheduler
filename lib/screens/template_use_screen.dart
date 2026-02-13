import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class TemplateUseScreen extends StatelessWidget {
  const TemplateUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Use Template',
      child: const Text(
        'TODO: Implement screen content per spec.',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
