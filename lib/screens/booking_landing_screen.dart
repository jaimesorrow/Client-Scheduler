import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/appointment.dart';
import '../data/models/invitation.dart';
import '../data/models/service.dart';
import '../data/repos/appointment_repository.dart';
import '../data/repos/invitation_repository.dart';
import '../data/repos/service_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

/// Public-facing booking screen reached via an invite link.
/// Does not require authentication.
class BookingLandingScreen extends StatefulWidget {
  const BookingLandingScreen({super.key});

  @override
  State<BookingLandingScreen> createState() =>
      _BookingLandingScreenState();
}

class _BookingLandingScreenState extends State<BookingLandingScreen> {
  final _invRepo = InvitationRepository();
  final _svcRepo = ServiceRepository();
  final _apptRepo = AppointmentRepository();

  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<(Invitation?, List<Service>)> _load(String token) async {
    final inv = await _invRepo.get(token);
    if (inv == null) return (null, <Service>[]);
    final services = await Future.wait(
      inv.serviceIds.map((id) => _svcRepo.get(inv.businessId, id)),
    );
    return (inv, services.whereType<Service>().toList());
  }

  Future<void> _book(Invitation inv, List<Service> services) async {
    if (_selectedDate == null || _selectedTime == null) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final startAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final totalMinutes = services.fold(
        0,
        (sum, s) => sum + s.durationMinutes,
      );
      final endAt = startAt.add(Duration(minutes: totalMinutes));

      // Create a pending appointment for the professional to confirm.
      final appt = Appointment(
        id: '',
        clientId: inv.clientEmail,
        serviceIds: inv.serviceIds,
        startAt: startAt,
        endAt: endAt,
        status: 'pending_client',
        notes: _notesController.text.trim().isEmpty
            ? 'Booked via invitation by ${inv.clientName}'
            : '${inv.clientName}: ${_notesController.text.trim()}',
        totalDurationMin: totalMinutes,
        totalPriceCents: services.fold<int>(
          0,
          (sum, s) => sum + (s.priceCents ?? 0),
        ),
      );

      await _apptRepo.create(inv.businessId, appt);
      await _invRepo.accept(inv.id);

      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (e) {
      setState(() => _error = 'Unable to submit booking. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final token =
        GoRouterState.of(context).pathParameters['token'] ?? '';
    return FutureBuilder<(Invitation?, List<Service>)>(
      future: _load(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ScreenScaffold(
            title: 'Book an appointment',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final inv = snapshot.data?.$1;
        final services = snapshot.data?.$2 ?? [];

        if (inv == null) {
          return ScreenScaffold(
            title: 'Booking',
            child: _invalidState(
              icon: Icons.link_off,
              message: 'This invite link is invalid or no longer exists.',
            ),
          );
        }
        if (inv.status == InvitationStatus.revoked) {
          return ScreenScaffold(
            title: 'Booking',
            child: _invalidState(
              icon: Icons.block,
              message: 'This invitation has been revoked.',
            ),
          );
        }
        if (inv.isExpired) {
          return ScreenScaffold(
            title: 'Booking',
            child: _invalidState(
              icon: Icons.timer_off_outlined,
              message: 'This invitation has expired. Please contact your provider for a new link.',
            ),
          );
        }
        if (inv.status == InvitationStatus.accepted) {
          return ScreenScaffold(
            title: 'Booking',
            child: _invalidState(
              icon: Icons.check_circle_outline,
              message: 'This invitation has already been used.',
              isSuccess: true,
            ),
          );
        }
        if (_submitted) {
          return ScreenScaffold(
            title: 'Booking confirmed',
            child: _successState(inv),
          );
        }

        return ScreenScaffold(
          title: 'Book an appointment',
          subtitle: 'You\'ve been invited by your provider',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(AppRadii.card),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${inv.clientName}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (inv.message != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          inv.message!,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Services
                const Text(
                  'Your appointment',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...services.map(
                  (svc) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            svc.name,
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text(
                          '${svc.durationMinutes} min',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Date picker
                const Text(
                  'Select a date',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDate == null
                        ? 'Choose date'
                        : _formatDate(_selectedDate!),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Time picker
                const Text(
                  'Select a time',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(
                    _selectedTime == null
                        ? 'Choose time'
                        : _selectedTime!.format(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Notes
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText:
                        'Any requests or things your provider should know',
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
                ElevatedButton(
                  onPressed: _selectedDate != null &&
                          _selectedTime != null &&
                          !_isSubmitting
                      ? () => _book(inv, services)
                      : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm booking'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _invalidState({
    required IconData icon,
    required String message,
    bool isSuccess = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 56,
            color: isSuccess ? AppColors.success : AppColors.muted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }

  Widget _successState(Invitation inv) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'You\'re all set, ${inv.clientName}!',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Your booking request has been received.\nYour provider will confirm your appointment shortly.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }
}
