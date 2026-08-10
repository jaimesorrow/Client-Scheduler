import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/client.dart';
import '../data/models/appointment.dart';
import '../data/repos/client_repository.dart';
import '../data/repos/appointment_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';
import '../widgets/screen_scaffold.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key});

  Future<(Client?, List<Appointment>)> _load(
    String businessId,
    String id,
  ) async {
    final client = await ClientRepository().get(businessId, id);
    if (client == null) return (null, <Appointment>[]);
    final appts = await AppointmentRepository().list(businessId);
    final clientAppts = appts
        .where((a) => a.clientId == id)
        .toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return (client, clientAppts);
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
      case 'no_show':
        return AppColors.muted;
      default:
        return AppColors.info;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No-show';
      case 'pending_client':
        return 'Pending';
      default:
        return 'Scheduled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Client',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Client',
          child: FutureBuilder<(Client?, List<Appointment>)>(
            future: _load(profile.businessId, id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final client = snapshot.data?.$1;
              final appts = snapshot.data?.$2 ?? [];
              if (client == null) {
                return const Text(
                  'Client not found.',
                  style: AppTextStyles.bodyMuted,
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.fullName, style: AppTextStyles.h1),
                    if (client.tags.contains('VIP')) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (client.phone != null || client.email != null)
                      Row(
                        children: [
                          if (client.phone != null) ...[
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone, size: 16),
                              label: Text(client.phone!),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          if (client.email != null)
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.email, size: 16),
                              label: const Text('Email'),
                            ),
                        ],
                      ),
                    if (client.notes != null &&
                        client.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const Text('Notes', style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.sm),
                      Text(client.notes!, style: AppTextStyles.bodyMuted),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Appointment history',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (appts.isEmpty)
                      const Text(
                        'No appointments yet.',
                        style: AppTextStyles.bodyMuted,
                      )
                    else
                      ...appts.take(10).map(
                            (a) => InkWell(
                              onTap: () =>
                                  context.go('/appointments/${a.id}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _fmtDate(a.startAt),
                                            style: AppTextStyles.body,
                                          ),
                                          Text(
                                            '${a.serviceIds.length} service${a.serviceIds.length == 1 ? '' : 's'} · ${formatDuration(a.totalDurationMin ?? 0)}',
                                            style: AppTextStyles.bodyMuted,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(a.status)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(AppRadii.pill),
                                      ),
                                      child: Text(
                                        _statusLabel(a.status),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _statusColor(a.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () =>
                          context.go('/appointments/new/client'),
                      child: const Text('Book appointment'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => context.go('/clients/$id/edit'),
                      child: const Text('Edit client'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () =>
                          context.go('/clients/$id/archive'),
                      child: Text(
                        client.isArchived
                            ? 'Restore client'
                            : 'Archive client',
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
