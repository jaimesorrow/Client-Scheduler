// lib/screens/onboarding_hours_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/business_settings_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

TimeOfDay _parseTime(String hhmm) {
  final parts = hhmm.split(':');
  return TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );
}

String _formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class OnboardingHoursScreen extends StatefulWidget {
  const OnboardingHoursScreen({super.key});

  @override
  State<OnboardingHoursScreen> createState() => _OnboardingHoursScreenState();
}

class _OnboardingHoursScreenState extends State<OnboardingHoursScreen> {
  final Map<String, bool> _days = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  late final Map<String, TimeOfDay> _openTimes = {
    for (final d in _kDays) d: _parseTime('09:00'),
  };

  late final Map<String, TimeOfDay> _closeTimes = {
    for (final d in _kDays) d: _parseTime('17:00'),
  };

  bool _isLoading = false;
  String? _error;

  Future<void> _pickTime(
    BuildContext context,
    String day,
    bool isOpen,
  ) async {
    final initial = isOpen ? _openTimes[day]! : _closeTimes[day]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openTimes[day] = picked;
        } else {
          _closeTimes[day] = picked;
        }
      });
    }
  }

  Future<void> _continue() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final workingHours = {
        for (final d in _kDays)
          d: {
            'open': _formatTime(_openTimes[d]!),
            'close': _formatTime(_closeTimes[d]!),
          },
      };
      await BusinessSettingsRepository().update(user.uid, {
        'workingDays': _days,
        'workingHours': workingHours,
      });
      if (!mounted) return;
      context.go('/onboarding/availability');
    } catch (e) {
      setState(() => _error = 'Unable to save hours. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Working hours',
      subtitle: 'Set your default hours for each day.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._kDays.map((day) => _OnboardingDayRow(
                        day: day,
                        enabled: _days[day]!,
                        openTime: _openTimes[day]!,
                        closeTime: _closeTimes[day]!,
                        isLoading: _isLoading,
                        onToggle: (val) =>
                            setState(() => _days[day] = val),
                        onPickOpen: () => _pickTime(context, day, true),
                        onPickClose: () => _pickTime(context, day, false),
                      )),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _continue,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _isLoading
                ? null
                : () => context.go('/onboarding/brand'),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class _OnboardingDayRow extends StatelessWidget {
  final String day;
  final bool enabled;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final bool isLoading;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  const _OnboardingDayRow({
    required this.day,
    required this.enabled,
    required this.openTime,
    required this.closeTime,
    required this.isLoading,
    required this.onToggle,
    required this.onPickOpen,
    required this.onPickClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(day, style: AppTextStyles.body),
            ),
            Switch(
              value: enabled,
              onChanged: isLoading ? null : onToggle,
              activeColor: AppColors.accent,
            ),
            if (enabled) ...[
              const Spacer(),
              _TimeChip(
                label: _formatTime(openTime),
                onTap: isLoading ? null : onPickOpen,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text('–', style: AppTextStyles.bodyMuted),
              ),
              _TimeChip(
                label: _formatTime(closeTime),
                onTap: isLoading ? null : onPickClose,
              ),
            ] else ...[
              const Spacer(),
              const Text('Closed', style: AppTextStyles.bodyMuted),
            ],
          ],
        ),
        const Divider(color: AppColors.divider, height: AppSpacing.lg),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _TimeChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
