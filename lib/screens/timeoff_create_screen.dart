// lib/screens/timeoff_create_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/timeoff_block.dart';
import '../data/repos/timeoff_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class TimeoffCreateScreen extends StatefulWidget {
  const TimeoffCreateScreen({super.key});

  @override
  State<TimeoffCreateScreen> createState() => _TimeoffCreateScreenState();
}

class _TimeoffCreateScreenState extends State<TimeoffCreateScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  bool get _isValid => _startDate != null && _endDate != null;

  Future<void> _save() async {
    if (!_isValid) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final businessId =
        context.read<UserProfileProvider>().profile?.businessId ?? '';

    try {
      final block = TimeoffBlock(
        id: '',
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );
      await TimeoffRepository().create(businessId, block);
      if (!mounted) return;
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
      title: 'Add Time Off',
      subtitle: 'Block dates when you are unavailable.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start date', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  _DatePickerField(
                    label: _startDate != null
                        ? _formatDate(_startDate!)
                        : 'Select start date',
                    onTap: _isLoading ? null : _pickStartDate,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('End date', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  _DatePickerField(
                    label: _endDate != null
                        ? _formatDate(_endDate!)
                        : 'Select end date',
                    onTap: _isLoading ? null : _pickEndDate,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _reasonController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Reason (optional)',
                      hintText: 'e.g. Vacation, Personal day',
                    ),
                    maxLines: 2,
                  ),
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
            onPressed: (_isValid && !_isLoading) ? _save : null,
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

class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _DatePickerField({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.muted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: onTap != null
                  ? AppTextStyles.body
                  : AppTextStyles.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}
