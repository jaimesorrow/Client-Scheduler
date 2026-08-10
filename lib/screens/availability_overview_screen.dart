// lib/screens/availability_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_repository.dart';
import '../data/business_settings.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class AvailabilityOverviewScreen extends StatelessWidget {
  const AvailabilityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final businessId =
        context.read<UserProfileProvider>().profile?.businessId ?? '';
    return FutureBuilder<BusinessSettings?>(
      future: BusinessSettingsRepository().getSettings(businessId),
      builder: (context, snapshot) {
        final settings = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return ScreenScaffold(
          title: 'Availability',
          subtitle: 'Manage when you accept appointments.',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Working days', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _buildDayChips(settings),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                const Text('Manage', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                _NavButton(
                  icon: Icons.schedule_outlined,
                  label: 'Edit Working Hours',
                  onTap: () => context.push('/availability/hours'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _NavButton(
                  icon: Icons.beach_access_outlined,
                  label: 'Time Off',
                  onTap: () => context.push('/availability/time-off'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _NavButton(
                  icon: Icons.view_week_outlined,
                  label: 'Week View',
                  onTap: () => context.push('/availability/week'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _NavButton(
                  icon: Icons.block_outlined,
                  label: 'Blackouts',
                  onTap: () => context.push('/availability/blackouts'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDayChips(BusinessSettings? settings) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final workingDays = settings?.workingDays ?? {};

    return days.map((day) {
      final enabled = workingDays[day] ?? false;
      return Chip(
        label: Text(day),
        labelStyle: TextStyle(
          color: enabled ? AppColors.surface : AppColors.muted,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        backgroundColor: enabled ? AppColors.accent : AppColors.bg,
        side: BorderSide(
          color: enabled ? AppColors.accent : AppColors.divider,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      );
    }).toList();
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: AppTextStyles.body),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
