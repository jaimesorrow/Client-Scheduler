import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsNotificationsScreen extends StatelessWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Notifications',
      child: const Text(
        'TODO: Implement screen content per spec.',
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
