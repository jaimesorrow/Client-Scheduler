// lib/screens/settings_policies_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_provider.dart';
import '../data/business_settings_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

const _kDefaultCancellation =
    'Cancellations must be made at least 24 hours in advance. '
    'Late cancellations may be subject to a cancellation fee of up to 50% of the service cost.';

const _kDefaultNoShow =
    'Clients who do not show up for their scheduled appointment without prior notice '
    'will be charged 100% of the service cost. Repeated no-shows may result in account suspension.';

class SettingsPoliciesScreen extends StatefulWidget {
  const SettingsPoliciesScreen({super.key});

  @override
  State<SettingsPoliciesScreen> createState() => _SettingsPoliciesScreenState();
}

class _SettingsPoliciesScreenState extends State<SettingsPoliciesScreen> {
  final _cancellationController =
      TextEditingController(text: _kDefaultCancellation);
  final _noShowController = TextEditingController(text: _kDefaultNoShow);
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _cancellationController.dispose();
    _noShowController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final businessId =
        context.read<UserProfileProvider>().profile?.businessId ?? '';
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await BusinessSettingsRepository().update(businessId, {
        'cancellationPolicy': _cancellationController.text.trim(),
        'noShowPolicy': _noShowController.text.trim(),
      });
      if (!mounted) return;
      context.read<BusinessSettingsProvider>().load(businessId);
      context.pop();
    } catch (e) {
      setState(() => _error = 'Unable to save policies. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Policies',
      subtitle: 'Set your cancellation and no-show policies.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cancellation policy', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _cancellationController,
                    maxLines: 5,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Describe your cancellation policy...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('No-show policy', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _noShowController,
                    maxLines: 5,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Describe your no-show policy...',
                      alignLabelWithHint: true,
                    ),
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
