// lib/screens/appt_reschedule_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointment_repository.dart';
import '../theme/tokens.dart';

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

class ApptRescheduleScreen extends StatefulWidget {
  const ApptRescheduleScreen({super.key});

  @override
  State<ApptRescheduleScreen> createState() => _ApptRescheduleScreenState();
}

class _ApptRescheduleScreenState extends State<ApptRescheduleScreen> {
  final _apptRepo = AppointmentRepository();

  Future<Appointment?>? _future;
  String? _apptId;
  String? _businessId;

  DateTime? _newDate;
  TimeOfDay? _newTime;
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

  Future<void> _pickDate(BuildContext context, DateTime initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newDate ?? initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _newDate = picked);
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initial) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _newTime ?? initial,
    );
    if (picked != null) setState(() => _newTime = picked);
  }

  Future<void> _save(
    BuildContext context,
    String businessId,
    Appointment appt,
  ) async {
    final date = _newDate;
    final time = _newTime;
    if (date == null || time == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newStart = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      final duration = appt.totalDurationMin ?? 0;
      final newEnd = newStart.add(Duration(minutes: duration));

      final updated = Appointment(
        id: appt.id,
        clientId: appt.clientId,
        serviceIds: appt.serviceIds,
        startAt: newStart,
        endAt: newEnd,
        status: appt.status,
        notes: appt.notes,
        totalDurationMin: appt.totalDurationMin,
        totalPriceCents: appt.totalPriceCents,
      );

      await _apptRepo.update(businessId, updated);
      if (!mounted) return;
      context.go('/appointments/${appt.id}');
    } catch (e) {
      setState(() => _error = 'Unable to reschedule. Please try again.');
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
              title: const Text('Reschedule'),
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
              'Reschedule',
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

              final currentDate = _newDate ?? appt.startAt;
              final currentTime =
                  _newTime ?? TimeOfDay.fromDateTime(appt.startAt);
              final canSave = _newDate != null || _newTime != null;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current appointment info
                      Text(
                        'Current: ${_fmtDate(appt.startAt)}  ·  '
                        '${_fmtTime(appt.startAt)}',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Date picker
                      const Text(
                        'New date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            _fmtDate(currentDate),
                            style: TextStyle(
                              color: _newDate != null
                                  ? AppColors.ink
                                  : AppColors.muted,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                          ),
                          onPressed: () =>
                              _pickDate(context, appt.startAt),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Time picker
                      const Text(
                        'New time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time_outlined),
                          label: Text(
                            _fmtTime(DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                              currentTime.hour,
                              currentTime.minute,
                            )),
                            style: TextStyle(
                              color: _newTime != null
                                  ? AppColors.ink
                                  : AppColors.muted,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                          ),
                          onPressed: () => _pickTime(
                            context,
                            TimeOfDay.fromDateTime(appt.startAt),
                          ),
                        ),
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
                          onPressed: (canSave && !_isLoading)
                              ? () => _save(
                                    context,
                                    profile.businessId,
                                    appt,
                                  )
                              : null,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save new time'),
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
