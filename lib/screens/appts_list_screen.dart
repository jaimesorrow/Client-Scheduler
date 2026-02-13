import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';
import '../utils/appointment_display.dart';

class ApptsListScreen extends StatelessWidget {
  const ApptsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real data from AppointmentRepository.
    final services = ['Cut', 'Color'];
    return ScreenScaffold(
      title: 'Appointments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ava Johnson'),
            subtitle: Text(summarizeServices(services)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('10:30 AM'),
                SizedBox(height: AppSpacing.xs),
                Text('Scheduled', style: TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const Divider(),
          const Text(
            'TODO: Replace with appointment list + filters.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
