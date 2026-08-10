// lib/screens/availability_hours_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_provider.dart';
import '../data/business_settings_repository.dart';
import '../data/business_settings.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class AvailabilityHoursScreen extends StatelessWidget {
  const AvailabilityHoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final businessId =
        context.read<UserProfileProvider>().profile?.businessId ?? '';
    return FutureBuilder<BusinessSettings?>(
      future: BusinessSettingsRepository().getSettings(businessId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _HoursEditor(
          businessId: businessId,
          settings: snapshot.data,
        );
      },
    );
  }
}

TimeOfDay _parseTime(String hhmm) {
  final parts = hhmm.split(':');
  return TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );
}

String _formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class _HoursEditor extends StatefulWidget {
  final String businessId;
  final BusinessSettings? settings;

  const _HoursEditor({required this.businessId, this.settings});

  @override
  State<_HoursEditor> createState() => _HoursEditorState();
}

class _HoursEditorState extends State<_HoursEditor> {
  late Map<String, bool> _days;
  late Map<String, TimeOfDay> _openTimes;
  late Map<String, TimeOfDay> _closeTimes;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _days = {
      for (final d in _kDays) d: s?.workingDays[d] ?? (d != 'Sat' && d != 'Sun'),
    };
    _openTimes = {
      for (final d in _kDays)
        d: _parseTime(s?.workingHours[d]?['open'] ?? '09:00'),
    };
    _closeTimes = {
      for (final d in _kDays)
        d: _parseTime(s?.workingHours[d]?['close'] ?? '17:00'),
    };
  }

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

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final workingHours = {
        for (final d in _kDays)
          d: {
            'open': _formatTime(_openTimes[d]!),
            'close': _formatTime(_closeTimes[d]!),
          },
      };
      await BusinessSettingsRepository().update(widget.businessId, {
        'workingDays': _days,
        'workingHours': workingHours,
      });
      if (!mounted) return;
      context.read<BusinessSettingsProvider>().load(widget.businessId);
      context.pop();
    } catch (e) {
      setState(() => _error = 'Unable to save. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Working Hours',
      subtitle: 'Set your hours for each day of the week.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._kDays.map((day) => _DayRow(
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
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String day;
  final bool enabled;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final bool isLoading;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  const _DayRow({
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
