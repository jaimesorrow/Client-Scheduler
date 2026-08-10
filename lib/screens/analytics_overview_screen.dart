// lib/screens/analytics_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/repos/appointment_repository.dart';
import '../data/repos/service_repository.dart';
import '../data/models/appointment.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';
import '../utils/appointment_display.dart';

class AnalyticsOverviewScreen extends StatefulWidget {
  const AnalyticsOverviewScreen({super.key});

  @override
  State<AnalyticsOverviewScreen> createState() =>
      _AnalyticsOverviewScreenState();
}

class _AnalyticsOverviewScreenState extends State<AnalyticsOverviewScreen> {
  final _apptRepo = AppointmentRepository();
  final _serviceRepo = ServiceRepository();

  Future<_AnalyticsData> _load(String businessId) async {
    final appointments = await _apptRepo.list(businessId);
    final now = DateTime.now();

    final completed =
        appointments.where((a) => a.status == 'completed').toList();
    final thisMonthAll = appointments
        .where(
          (a) =>
              a.startAt.year == now.year && a.startAt.month == now.month,
        )
        .toList();
    final thisMonthCompleted = completed
        .where(
          (a) =>
              a.startAt.year == now.year && a.startAt.month == now.month,
        )
        .toList();

    final revenueMonth = thisMonthCompleted.fold(
      0,
      (sum, a) => sum + (a.totalPriceCents ?? 0),
    );
    final revenueAllTime = completed.fold(
      0,
      (sum, a) => sum + (a.totalPriceCents ?? 0),
    );

    final cancelledCount =
        appointments.where((a) => a.status == 'cancelled').length;
    final noShowCount =
        appointments.where((a) => a.status == 'no_show').length;
    final completedCount = completed.length;

    // Top service among completed appointments
    final serviceFreq = <String, int>{};
    for (final appt in completed) {
      for (final sid in appt.serviceIds) {
        serviceFreq[sid] = (serviceFreq[sid] ?? 0) + 1;
      }
    }
    String? topServiceName;
    if (serviceFreq.isNotEmpty) {
      final topId = serviceFreq.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      final svc = await _serviceRepo.get(businessId, topId);
      topServiceName = svc?.name;
    }

    return _AnalyticsData(
      revenueMonth: revenueMonth,
      revenueAllTime: revenueAllTime,
      thisMonthCount: thisMonthAll.length,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      noShowCount: noShowCount,
      topServiceName: topServiceName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Analytics',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ScreenScaffold(
          title: 'Analytics',
          subtitle: 'Business performance overview',
          child: FutureBuilder<_AnalyticsData>(
            future: _load(profile.businessId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Unable to load analytics.',
                    style: AppTextStyles.bodyMuted,
                  ),
                );
              }

              final data = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Revenue section
                    _SectionHeader(
                      label: 'Revenue',
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'This Month',
                            value: formatPrice(data.revenueMonth),
                            icon: Icons.trending_up,
                            iconColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            label: 'All Time',
                            value: formatPrice(data.revenueAllTime),
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Appointments section
                    _SectionHeader(
                      label: 'Appointments',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatCardWide(
                      label: 'This Month',
                      value: '${data.thisMonthCount}',
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.info,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Completed',
                            value: '${data.completedCount}',
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            label: 'Cancelled',
                            value: '${data.cancelledCount}',
                            icon: Icons.cancel_outlined,
                            iconColor: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatCardWide(
                      label: 'No-Shows',
                      value: '${data.noShowCount}',
                      icon: Icons.person_off_outlined,
                      iconColor: AppColors.warning,
                    ),

                    if (data.topServiceName != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(
                        label: 'Top Service',
                        icon: Icons.star_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _StatCardWide(
                        label: 'Most Booked',
                        value: data.topServiceName!,
                        icon: Icons.star_outline,
                        iconColor: AppColors.accent,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AnalyticsData {
  final int revenueMonth;
  final int revenueAllTime;
  final int thisMonthCount;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;
  final String? topServiceName;

  const _AnalyticsData({
    required this.revenueMonth,
    required this.revenueAllTime,
    required this.thisMonthCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
    this.topServiceName,
  });
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCardWide({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMuted),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
