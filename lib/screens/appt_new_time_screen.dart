// lib/screens/appt_new_time_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/appointment_draft_provider.dart';
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

String _fmtTimeOfDay(TimeOfDay t) {
  final h = t.hour;
  final period = h < 12 ? 'AM' : 'PM';
  final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$displayH:${t.minute.toString().padLeft(2, '0')} $period';
}

class ApptNewTimeScreen extends StatefulWidget {
  const ApptNewTimeScreen({super.key});

  @override
  State<ApptNewTimeScreen> createState() => _ApptNewTimeScreenState();
}

class _ApptNewTimeScreenState extends State<ApptNewTimeScreen> {
  DateTime? _date;
  TimeOfDay? _time;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  bool get _canContinue => _date != null && _time != null;

  void _onContinue(BuildContext context) {
    context.read<AppointmentDraftProvider>().setDateTime(_date!, _time!);
    context.go('/appointments/new/review');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final draft = context.read<AppointmentDraftProvider>();
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            foregroundColor: AppColors.ink,
            leading: BackButton(
              onPressed: () => context.go('/appointments/new/service'),
            ),
            title: const Text(
              'New Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 3 of 4 — Choose date & time',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Draft summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.clientName ?? 'No client selected',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (draft.serviceNames.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            summarizeServices(draft.serviceNames),
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                        if (draft.totalDurationMin > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            formatDuration(draft.totalDurationMin),
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Date picker button
                  const Text(
                    'Date',
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
                        _date != null ? _fmtDate(_date!) : 'Select date',
                        style: TextStyle(
                          color: _date != null ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () => _pickDate(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Time picker button
                  const Text(
                    'Time',
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
                        _time != null
                            ? _fmtTimeOfDay(_time!)
                            : 'Select time',
                        style: TextStyle(
                          color: _time != null ? AppColors.ink : AppColors.muted,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () => _pickTime(context),
                    ),
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canContinue ? () => _onContinue(context) : null,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
