// lib/screens/activity_feed_screen.dart
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

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final _apptRepo = AppointmentRepository();
  final _clientRepo = ClientRepository();

  Future<(List<Appointment>, Map<String, Client>)> _load(
    String businessId,
  ) async {
    final apptFuture = _apptRepo.list(businessId);
    final clientFuture = _clientRepo.list(businessId, includeArchived: true);
    final appointments = await apptFuture;
    final clients = await clientFuture;
    final clientMap = {for (final c in clients) c.id: c};

    // Sort by most recent startAt, limit to 50
    appointments.sort((a, b) => b.startAt.compareTo(a.startAt));
    final limited = appointments.take(50).toList();
    return (limited, clientMap);
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dayName, $month ${dt.day} · $h:$minute $period';
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.person_off;
      case 'pending_client':
        return Icons.hourglass_top;
      default:
        return Icons.calendar_today;
    }
  }

  Color _statusColor(String status) {
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

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      case 'pending_client':
        return 'Pending';
      case 'scheduled':
        return 'Scheduled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Activity',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ScreenScaffold(
          title: 'Activity',
          subtitle: 'Recent appointments',
          child: FutureBuilder<(List<Appointment>, Map<String, Client>)>(
            future: _load(profile.businessId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Unable to load activity.',
                    style: AppTextStyles.bodyMuted,
                  ),
                );
              }

              final (appointments, clientMap) = snapshot.data!;

              if (appointments.isEmpty) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'No activity yet.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Appointments will appear here as they are created.',
                      style: AppTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }

              return ListView.separated(
                itemCount: appointments.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 60),
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final client = clientMap[appt.clientId];
                  final color = _statusColor(appt.status);

                  return InkWell(
                    onTap: () =>
                        context.go('/appointments/${appt.id}'),
                    borderRadius:
                        BorderRadius.circular(AppRadii.card),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Status icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _statusIcon(appt.status),
                              color: color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        client?.fullName ??
                                            'Unknown client',
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.pill,
                                        ),
                                      ),
                                      child: Text(
                                        _statusLabel(appt.status),
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _formatDateTime(appt.startAt),
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                            size: 20,
                          ),
                        ],
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
