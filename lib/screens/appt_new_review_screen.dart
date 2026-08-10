// lib/screens/appt_new_review_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/appointment_draft_provider.dart';
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

class ApptNewReviewScreen extends StatefulWidget {
  const ApptNewReviewScreen({super.key});

  @override
  State<ApptNewReviewScreen> createState() => _ApptNewReviewScreenState();
}

class _ApptNewReviewScreenState extends State<ApptNewReviewScreen> {
  final _apptRepo = AppointmentRepository();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirm(BuildContext context, String businessId) async {
    final draft = context.read<AppointmentDraftProvider>();
    if (!draft.isReadyToBook) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appt = Appointment(
        id: '',
        clientId: draft.clientId!,
        serviceIds: draft.serviceIds,
        startAt: draft.startAt!,
        endAt: draft.endAt!,
        status: 'scheduled',
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        totalDurationMin: draft.totalDurationMin,
        totalPriceCents: draft.totalPriceCents,
      );
      await _apptRepo.create(businessId, appt);
      draft.clear(); // always clear after successful create
      if (!mounted) return;
      context.go('/appointments');
    } catch (e) {
      setState(() => _error = 'Unable to book appointment. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        final draft = context.read<AppointmentDraftProvider>();

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            foregroundColor: AppColors.ink,
            leading: BackButton(
              onPressed: () => context.go('/appointments/new/time'),
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
                    'Step 4 of 4 — Review & confirm',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client
                          _SectionLabel(label: 'Client'),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            draft.clientName ?? '—',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Services
                          _SectionLabel(label: 'Services'),
                          const SizedBox(height: AppSpacing.sm),
                          ...List.generate(draft.serviceNames.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Text(
                                draft.serviceNames[i],
                                style: AppTextStyles.body,
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.xl),

                          // Date & Time
                          _SectionLabel(label: 'Date & time'),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            draft.startAt != null
                                ? '${_fmtDate(draft.startAt!)}  ·  '
                                    '${_fmtTime(draft.startAt!)}'
                                : '—',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Summary row
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.card),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Duration',
                                      style: AppTextStyles.bodyMuted,
                                    ),
                                    Text(
                                      formatDuration(draft.totalDurationMin),
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
                                    Text(
                                      formatPrice(draft.totalPriceCents),
                                      style: AppTextStyles.body,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Notes
                          _SectionLabel(label: 'Notes (optional)'),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText:
                                  'Add any notes for this appointment...',
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _error!,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (profile != null &&
                              draft.isReadyToBook &&
                              !_isLoading)
                          ? () => _confirm(context, profile.businessId)
                          : null,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm booking'),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.5,
      ),
    );
  }
}
