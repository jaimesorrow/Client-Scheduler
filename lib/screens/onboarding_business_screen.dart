// lib/screens/onboarding_business_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/business_settings_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

const _kTimezones = [
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'America/Anchorage',
  'Pacific/Honolulu',
  'Europe/London',
  'Europe/Paris',
  'Asia/Tokyo',
  'Australia/Sydney',
];

class OnboardingBusinessScreen extends StatefulWidget {
  const OnboardingBusinessScreen({super.key});

  @override
  State<OnboardingBusinessScreen> createState() =>
      _OnboardingBusinessScreenState();
}

class _OnboardingBusinessScreenState extends State<OnboardingBusinessScreen> {
  final _nameController = TextEditingController();
  String _timezone = 'America/New_York';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await BusinessSettingsRepository().update(user.uid, {
        'businessName': _nameController.text.trim(),
        'timezone': _timezone,
      });
      if (!mounted) return;
      context.go('/onboarding/availability');
    } catch (e) {
      setState(() {
        _error = 'Unable to save. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Your business',
      subtitle: 'These settings power scheduling.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Business name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _timezone,
            items: _kTimezones
                .map((tz) => DropdownMenuItem(
                      value: tz,
                      child: Text(tz),
                    ))
                .toList(),
            onChanged: _isLoading
                ? null
                : (val) => setState(() => _timezone = val ?? _timezone),
            decoration: const InputDecoration(labelText: 'Timezone'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            enabled: false,
            decoration: const InputDecoration(labelText: 'Currency (USD)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: _isValid && !_isLoading ? _save : null,
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
            onPressed:
                _isLoading ? null : () => context.go('/onboarding/welcome'),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
