import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_repository.dart';
import '../data/business_settings.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

/// Weekly schedule view — shows each enabled day with its hours.
class AvailabilityWeekScreen extends StatefulWidget {
  const AvailabilityWeekScreen({super.key});

  @override
  State<AvailabilityWeekScreen> createState() =>
      _AvailabilityWeekScreenState();
}

class _AvailabilityWeekScreenState extends State<AvailabilityWeekScreen> {
  static const _days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  Future<BusinessSettings?> _load(String businessId) =>
      BusinessSettingsRepository().getSettings(businessId);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Weekly Schedule',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Weekly Schedule',
          subtitle: 'Your working hours at a glance',
          child: FutureBuilder<BusinessSettings?>(
            future: _load(profile.businessId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final settings = snapshot.data;
              if (settings == null) {
                return const Text(
                  'No availability configured yet.',
                  style: AppTextStyles.bodyMuted,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._days.map((day) {
                    final enabled = settings.workingDays[day] ?? false;
                    final hours = settings.workingHours[day];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: enabled
                            ? AppColors.surface
                            : AppColors.bg,
                        borderRadius:
                            BorderRadius.circular(AppRadii.card),
                        border: Border.all(
                          color: AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text(
                              day,
                              style: AppTextStyles.body.copyWith(
                                color: enabled
                                    ? AppColors.ink
                                    : AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Text(
                            enabled
                                ? '${hours?['open'] ?? '09:00'} – ${hours?['close'] ?? '17:00'}'
                                : 'Closed',
                            style: AppTextStyles.body.copyWith(
                              color: enabled
                                  ? AppColors.ink
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () =>
                        context.go('/availability/hours'),
                    child: const Text('Edit working hours'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
