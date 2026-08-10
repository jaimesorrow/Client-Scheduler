// lib/screens/dashboard_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/repos/appointment_repository.dart';
import '../data/repos/client_repository.dart';
import '../data/models/appointment.dart';
import '../data/models/client.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _apptRepo = AppointmentRepository();
  final _clientRepo = ClientRepository();

  Future<(List<Appointment>, List<Client>)> _load(String businessId) async {
    final apptFuture = _apptRepo.list(businessId);
    final clientFuture = _clientRepo.list(businessId, includeArchived: true);
    return (await apptFuture, await clientFuture);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Dashboard',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ScreenScaffold(
          title: _greeting,
          subtitle: "Here's what's happening today",
          child: FutureBuilder<(List<Appointment>, List<Client>)>(
            future: _load(profile.businessId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Unable to load dashboard.',
                    style: AppTextStyles.bodyMuted,
                  ),
                );
              }
              final (appointments, clients) = snapshot.data!;
              final clientMap = {for (final c in clients) c.id: c};
              final now = DateTime.now();
              final todayAppts = appointments
                  .where(
                    (a) =>
                        a.startAt.year == now.year &&
                        a.startAt.month == now.month &&
                        a.startAt.day == now.day,
                  )
                  .toList()
                ..sort((a, b) => a.startAt.compareTo(b.startAt));
              final thisMonthAppts = appointments
                  .where(
                    (a) =>
                        a.startAt.year == now.year &&
                        a.startAt.month == now.month,
                  )
                  .toList();
              final nonArchivedCount = clients.where((c) => !c.isArchived).length;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's appointments
                    Text(
                      "Today's Appointments",
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (todayAppts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        child: Text(
                          'No appointments today.',
                          style: AppTextStyles.bodyMuted,
                        ),
                      )
                    else
                      ...todayAppts.map((appt) {
                        final client = clientMap[appt.clientId];
                        return _ApptCard(
                          time: _formatTime(appt.startAt),
                          clientName: client?.fullName ?? 'Unknown client',
                          serviceCount: appt.serviceIds.length,
                          status: appt.status,
                          onTap: () => context.go('/appointments/${appt.id}'),
                        );
                      }),

                    const SizedBox(height: AppSpacing.xl),

                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 2.2,
                      children: [
                        _QuickActionCard(
                          icon: Icons.add_circle_outline,
                          label: 'New Appointment',
                          onTap: () =>
                              context.go('/appointments/new/client'),
                        ),
                        _QuickActionCard(
                          icon: Icons.calendar_month_outlined,
                          label: 'All Appointments',
                          onTap: () => context.go('/appointments'),
                        ),
                        _QuickActionCard(
                          icon: Icons.people_outline,
                          label: 'Clients',
                          onTap: () => context.go('/clients'),
                        ),
                        _QuickActionCard(
                          icon: Icons.mail_outline,
                          label: 'Invitations',
                          onTap: () => context.go('/invitations'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Stats row
                    Text(
                      'Overview',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Clients',
                            value: '$nonArchivedCount',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            label: 'This Month',
                            value: '${thisMonthAppts.length}',
                            sublabel: 'appointments',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Invitations link
                    GestureDetector(
                      onTap: () => context.go('/invitations'),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.send_outlined,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Manage Invitations',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.accent,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
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

class _ApptCard extends StatelessWidget {
  final String time;
  final String clientName;
  final int serviceCount;
  final String status;
  final VoidCallback onTap;

  const _ApptCard({
    required this.time,
    required this.clientName,
    required this.serviceCount,
    required this.status,
    required this.onTap,
  });

  Color _statusColor() {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      case 'no_show':
        return AppColors.warning;
      case 'pending_client':
        return AppColors.info;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$time · $serviceCount service${serviceCount == 1 ? '' : 's'}',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadii.card),
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodyMuted.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;

  const _StatCard({
    required this.label,
    required this.value,
    this.sublabel,
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
            Text(label, style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(color: AppColors.accent),
            ),
            if (sublabel != null)
              Text(sublabel!, style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
    );
  }
}
