// lib/screens/settings_business_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/business_settings_provider.dart';
import '../data/business_settings_repository.dart';
import '../data/business_settings.dart';
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

class SettingsBusinessProfileScreen extends StatelessWidget {
  const SettingsBusinessProfileScreen({super.key});

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
        return _BusinessProfileForm(
          businessId: businessId,
          settings: snapshot.data,
        );
      },
    );
  }
}

class _BusinessProfileForm extends StatefulWidget {
  final String businessId;
  final BusinessSettings? settings;

  const _BusinessProfileForm({required this.businessId, this.settings});

  @override
  State<_BusinessProfileForm> createState() => _BusinessProfileFormState();
}

class _BusinessProfileFormState extends State<_BusinessProfileForm> {
  late final TextEditingController _nameController;
  late String _timezone;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.settings?.businessName ?? '',
    );
    _timezone = widget.settings?.timezone ?? 'America/New_York';
    if (!_kTimezones.contains(_timezone)) {
      _timezone = 'America/New_York';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await BusinessSettingsRepository().update(widget.businessId, {
        'businessName': _nameController.text.trim(),
        'timezone': _timezone,
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
      title: 'Business Profile',
      subtitle: 'Update your business information.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Business name'),
                    onChanged: (_) => setState(() {}),
                    enabled: !_isLoading,
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
                        : (val) =>
                            setState(() => _timezone = val ?? _timezone),
                    decoration: const InputDecoration(labelText: 'Timezone'),
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
