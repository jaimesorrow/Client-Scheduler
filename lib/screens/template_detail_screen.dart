import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class TemplateDetailScreen extends StatelessWidget {
  const TemplateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Template Detail',
      child: const Text(
        'TODO: Implement screen content per spec.',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
