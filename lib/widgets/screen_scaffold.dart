import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class ScreenScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const ScreenScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h1),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle!, style: AppTextStyles.bodyMuted),
              ],
              const SizedBox(height: AppSpacing.xl),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
