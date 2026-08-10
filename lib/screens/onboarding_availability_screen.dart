// lib/screens/onboarding_availability_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_provider.dart';
import '../data/business_settings_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class OnboardingAvailabilityScreen extends StatefulWidget {
  const OnboardingAvailabilityScreen({super.key});

  @override
  State<OnboardingAvailabilityScreen> createState() =>
      _OnboardingAvailabilityScreenState();
}

class _OnboardingAvailabilityScreenState
    extends State<OnboardingAvailabilityScreen> {
  final Map<String, bool> _enabled = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };
  bool _isLoading = false;
  String? _error;

  Future<void> _finish() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await BusinessSettingsRepository().setOnboardingComplete(user.uid);
      await BusinessSettingsRepository()
          .update(user.uid, {'workingDays': _enabled});
      if (!mounted) return;
      context.read<BusinessSettingsProvider>().markOnboardingComplete();
      context.read<UserProfileProvider>().load(user.uid);
      context.go('/dashboard');
    } catch (e) {
      setState(() {
        _error = 'Unable to save availability.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Availability',
      subtitle: 'Set when you accept appointments.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._enabled.keys.map((day) {
            return SwitchListTile(
              value: _enabled[day]!,
              onChanged: _isLoading
                  ? null
                  : (val) => setState(() => _enabled[day] = val),
              title: Text(day, style: AppTextStyles.body),
              contentPadding: EdgeInsets.zero,
            );
          }),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: _isLoading ? null : _finish,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Finish setup'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed:
                _isLoading ? null : () => context.go('/onboarding/business'),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
