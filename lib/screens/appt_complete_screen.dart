// lib/screens/appt_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointment_repository.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';

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

class ApptCompleteScreen extends StatefulWidget {
  const ApptCompleteScreen({super.key});

  @override
  State<ApptCompleteScreen> createState() => _ApptCompleteScreenState();
}

class _ApptCompleteScreenState extends State<ApptCompleteScreen> {
  final _apptRepo = AppointmentRepository();

  Future<Appointment?>? _future;
  String? _apptId;
  String? _businessId;
  bool _isLoading = false;
  String? _error;

  Future<Appointment?> _loadAppointment(
    String businessId,
    String apptId,
  ) async {
    final appts = await _apptRepo.list(businessId);
    try {
      return appts.firstWhere((a) => a.id == apptId);
    } catch (_) {
      return null;
    }
  }

  void _maybeLoad(String businessId, String apptId) {
    if (apptId != _apptId || businessId != _businessId) {
      _apptId = apptId;
      _businessId = businessId;
      _future = _loadAppointment(businessId, apptId);
    }
  }

  Future<void> _confirm(
    BuildContext context,
    String businessId,
    Appointment appt,
  ) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final updated = Appointment(
        id: appt.id,
        clientId: appt.clientId,
        serviceIds: appt.serviceIds,
        startAt: appt.startAt,
        endAt: appt.endAt,
        status: 'completed',
        notes: appt.notes,
        totalDurationMin: appt.totalDurationMin,
        totalPriceCents: appt.totalPriceCents,
      );
      await _apptRepo.update(businessId, updated);
      if (!mounted) return;
      context.go('/appointments');
    } catch (e) {
      setState(() => _error = 'Unable to update appointment. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                onPressed: () => context.go('/appointments/$apptId'),
              ),
              title: const Text('Mark Complete'),
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
              onPressed: () => context.go('/appointments/$apptId'),
            ),
            title: const Text(
              'Mark Complete',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          body: FutureBuilder<Appointment?>(
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
              final appt = snapshot.data;
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
                      // Success icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadii.card),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      const Text(
                        'Mark as completed?',
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${_fmtDate(appt.startAt)}  ·  ${_fmtTime(appt.startAt)}',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Summary card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Duration',
                                  style: AppTextStyles.bodyMuted,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  formatDuration(appt.totalDurationMin ?? 0),
                                  style: AppTextStyles.body,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total',
                                  style: AppTextStyles.bodyMuted,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  formatPrice(appt.totalPriceCents),
                                  style: AppTextStyles.body,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'This will mark the appointment as completed and '
                        'record it in the client\'s history.',
                        style: AppTextStyles.bodyMuted,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ],

                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.surface,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _confirm(
                                    context,
                                    profile.businessId,
                                    appt,
                                  ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.surface,
                                  ),
                                )
                              : const Text('Mark as completed'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go('/appointments/$apptId'),
                          child: const Text('Go back'),
                        ),
                      ),
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
