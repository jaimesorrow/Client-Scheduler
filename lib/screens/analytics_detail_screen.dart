import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointment_repository.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';
import '../widgets/screen_scaffold.dart';

/// Monthly revenue breakdown detail screen.
class AnalyticsDetailScreen extends StatefulWidget {
  const AnalyticsDetailScreen({super.key});

  @override
  State<AnalyticsDetailScreen> createState() => _AnalyticsDetailScreenState();
}

class _AnalyticsDetailScreenState extends State<AnalyticsDetailScreen> {
  final _repo = AppointmentRepository();

  Future<List<Appointment>> _load(String businessId) =>
      _repo.list(businessId);

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Revenue Detail',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Revenue Detail',
          subtitle: 'Monthly breakdown',
          child: FutureBuilder<List<Appointment>>(
            future: _load(profile.businessId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = (snapshot.data ?? [])
                  .where((a) => a.status == 'completed')
                  .toList();

              // Build monthly map
              final Map<String, int> monthly = {};
              for (final appt in all) {
                final key =
                    '${appt.startAt.year}-${appt.startAt.month.toString().padLeft(2, '0')}';
                monthly[key] =
                    (monthly[key] ?? 0) + (appt.totalPriceCents ?? 0);
              }
              final sorted = monthly.entries.toList()
                ..sort((a, b) => b.key.compareTo(a.key));

              if (sorted.isEmpty) {
                return const Center(
                  child: Text(
                    'No completed appointments yet.',
                    style: AppTextStyles.bodyMuted,
                  ),
                );
              }

              return ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final entry = sorted[i];
                  final parts = entry.key.split('-');
                  final year = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final label = '${_months[month - 1]} $year';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    trailing: Text(
                      formatPrice(entry.value),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
