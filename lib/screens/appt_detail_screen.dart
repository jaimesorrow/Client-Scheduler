import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';
import '../utils/appointment_display.dart';

class ApptDetailScreen extends StatelessWidget {
  const ApptDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'name': 'Cut', 'duration': 45, 'price': 4500},
      {'name': 'Color', 'duration': 60, 'price': 8500},
    ];
    final totalDuration = services.fold<int>(
      0,
      (sum, s) => sum + (s['duration'] as int),
    );
    final totalPrice = services.fold<int>(
      0,
      (sum, s) => sum + (s['price'] as int),
    );
    return ScreenScaffold(
      title: 'Appointment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services', style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          ...services.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s['name'] as String),
                  Text(
                    '${formatDuration(s['duration'] as int)} · ${formatPrice(s['price'] as int)}',
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text(
                '${formatDuration(totalDuration)} · ${formatPrice(totalPrice)}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'TODO: Replace with live appointment data, status actions, and audit log.',
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
