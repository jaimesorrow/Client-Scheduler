import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SystemHubScreen extends StatelessWidget {
  const SystemHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final mode = state.uri.queryParameters['mode'] ?? 'error';
    final from = state.uri.queryParameters['from'] ?? '/dashboard';

    if (mode == 'permission') {
      return ScreenScaffold(
        title: 'Access denied',
        subtitle: 'This area is owner-only.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You don’t have permission to view this page.',
              style: AppTextStyles.body,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Back to dashboard'),
            ),
          ],
        ),
      );
    }

    return ScreenScaffold(
      title: 'Something went wrong',
      subtitle: 'Try again or return to safety.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We hit an unexpected error. Your data is safe.',
            style: AppTextStyles.body,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.go(from),
            child: const Text('Try again'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Go to dashboard'),
          ),
        ],
      ),
    );
  }
}
