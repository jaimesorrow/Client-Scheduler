// lib/screens/appt_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/models/appointment.dart';
import '../data/models/client.dart';
import '../data/models/service.dart';
import '../data/repos/appointment_repository.dart';
import '../data/repos/client_repository.dart';
import '../data/repos/service_repository.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';

typedef _DetailData = (Appointment?, Client?, List<Service>);

String _fmtDate(DateTime d) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

String _fmtTime(DateTime d) {
  final h = d.hour;
  final period = h < 12 ? 'AM' : 'PM';
  final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$displayH:${d.minute.toString().padLeft(2, '0')} $period';
}

Widget _statusBadge(String status) {
  final (color, label) = switch (status) {
    'scheduled' => (AppColors.info, 'Scheduled'),
    'completed' => (AppColors.success, 'Completed'),
    'cancelled' => (AppColors.muted, 'Cancelled'),
    'no_show' => (AppColors.warning, 'No Show'),
    'pending_client' => (AppColors.warning, 'Pending'),
    _ => (AppColors.muted, status),
  };
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

class ApptDetailScreen extends StatefulWidget {
  const ApptDetailScreen({super.key});

  @override
  State<ApptDetailScreen> createState() => _ApptDetailScreenState();
}

class _ApptDetailScreenState extends State<ApptDetailScreen> {
  final _apptRepo = AppointmentRepository();
  final _clientRepo = ClientRepository();
  final _serviceRepo = ServiceRepository();

  Future<_DetailData>? _future;
  String? _apptId;
  String? _businessId;

  Future<_DetailData> _loadDetail(
    String businessId,
    String apptId,
  ) async {
    final appts = await _apptRepo.list(businessId);
    final Appointment appt;
    try {
      appt = appts.firstWhere((a) => a.id == apptId);
    } catch (_) {
      return (null, null, const []);
    }

    final clientFut = _clientRepo.get(businessId, appt.clientId);
    final servicesFut = _serviceRepo.list(businessId, includeArchived: true);

    final client = await clientFut;
    final allServices = await servicesFut;

    final apptServices = allServices
        .where((s) => appt.serviceIds.contains(s.id))
        .toList();

    return (appt, client, apptServices);
  }

  void _maybeLoad(String businessId, String apptId) {
    if (apptId != _apptId || businessId != _businessId) {
      _apptId = apptId;
      _businessId = businessId;
      _future = _loadDetail(businessId, apptId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apptId = GoRouterState.of(context).pathParameters['id'] ?? '';

    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            appBar: AppBar(
              backgroundColor: AppColors.bg,
              elevation: 0,
              foregroundColor: AppColors.ink,
              leading: BackButton(
                onPressed: () => context.go('/appointments'),
              ),
              title: const Text('Appointment'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        _maybeLoad(profile.businessId, apptId);

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            foregroundColor: AppColors.ink,
            leading: BackButton(
              onPressed: () => context.go('/appointments'),
            ),
            title: const Text(
              'Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          body: FutureBuilder<_DetailData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Unable to load appointment.',
                    style: AppTextStyles.bodyMuted,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final (appt, client, services) = snapshot.data!;
              if (appt == null) {
                return const Center(
                  child: Text(
                    'Appointment not found.',
                    style: AppTextStyles.bodyMuted,
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Client name + status
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      client?.fullName ?? 'Unknown Client',
                                      style: AppTextStyles.h1,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.xs,
                                    ),
                                    child: _statusBadge(appt.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Date & time
                              Text(
                                '${_fmtDate(appt.startAt)}  ·  '
                                '${_fmtTime(appt.startAt)}',
                                style: AppTextStyles.bodyMuted,
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Services section
                              _DetailSection(
                                label: 'Services',
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    ...services.map(
                                      (s) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(s.name),
                                            ),
                                            Text(
                                              '${formatDuration(s.durationMinutes)}'
                                              '${s.priceCents != null ? '  ·  ${formatPrice(s.priceCents)}' : ''}',
                                              style: AppTextStyles.bodyMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (services.isEmpty)
                                      const Text(
                                        'No service details available.',
                                        style: AppTextStyles.bodyMuted,
                                      ),
                                  ],
                                ),
                              ),
                              const Divider(height: AppSpacing.xxxl),

                              // Total row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${formatDuration(appt.totalDurationMin ?? 0)}'
                                    '  ·  ${formatPrice(appt.totalPriceCents)}',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // Notes
                              if (appt.notes != null &&
                                  appt.notes!.isNotEmpty) ...[
                                _DetailSection(
                                  label: 'Notes',
                                  child: Text(appt.notes!),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Action buttons
                      if (appt.status == 'scheduled') ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.surface,
                            ),
                            onPressed: () => context.go(
                              '/appointments/${appt.id}/complete',
                            ),
                            child: const Text('Mark complete'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go(
                              '/appointments/${appt.id}/reschedule',
                            ),
                            child: const Text('Reschedule'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.warning,
                                  side: const BorderSide(
                                    color: AppColors.warning,
                                  ),
                                ),
                                onPressed: () => context.go(
                                  '/appointments/${appt.id}/no-show',
                                ),
                                child: const Text('No-show'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(
                                    color: AppColors.danger,
                                  ),
                                ),
                                onPressed: () => context.go(
                                  '/appointments/${appt.id}/cancel',
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (appt.status == 'pending_client') ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                            ),
                            onPressed: () => context.go(
                              '/appointments/${appt.id}/cancel',
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _DetailSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
