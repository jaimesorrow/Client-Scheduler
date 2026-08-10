// lib/screens/settings_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() =>
      _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState
    extends State<SettingsNotificationsScreen> {
  bool _appointmentReminders = true;
  bool _newBookingRequests = true;
  bool _cancellations = true;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Notifications',
      subtitle: 'Control which alerts you receive.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Appointment reminders',
                    style: AppTextStyles.body,
                  ),
                  subtitle: const Text(
                    'Get reminded before upcoming appointments.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  value: _appointmentReminders,
                  onChanged: (val) =>
                      setState(() => _appointmentReminders = val),
                  activeColor: AppColors.accent,
                ),
                const Divider(color: AppColors.divider),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'New booking requests',
                    style: AppTextStyles.body,
                  ),
                  subtitle: const Text(
                    'Notify when clients request a booking.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  value: _newBookingRequests,
                  onChanged: (val) =>
                      setState(() => _newBookingRequests = val),
                  activeColor: AppColors.accent,
                ),
                const Divider(color: AppColors.divider),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Cancellations',
                    style: AppTextStyles.body,
                  ),
                  subtitle: const Text(
                    'Notify when an appointment is cancelled.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  value: _cancellations,
                  onChanged: (val) =>
                      setState(() => _cancellations = val),
                  activeColor: AppColors.accent,
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: const Text(
                    'Notification delivery coming soon. Settings are saved but not yet active.',
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
