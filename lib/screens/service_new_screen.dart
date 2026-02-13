import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/service.dart';
import '../data/repos/service_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ServiceNewScreen extends StatefulWidget {
  const ServiceNewScreen({super.key});

  @override
  State<ServiceNewScreen> createState() => _ServiceNewScreenState();
}

class _ServiceNewScreenState extends State<ServiceNewScreen> {
  final _repo = ServiceRepository();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final nameOk = _nameController.text.trim().isNotEmpty;
    final duration = int.tryParse(_durationController.text.trim());
    final durationOk = duration != null && duration > 0;
    final price = int.tryParse(_priceController.text.trim());
    final priceOk =
        _priceController.text.trim().isEmpty || (price != null && price >= 0);
    return nameOk && durationOk && priceOk;
  }

  Future<void> _save(String businessId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final price = int.tryParse(_priceController.text.trim());
      final service = Service(
        id: '',
        name: _nameController.text.trim(),
        durationMinutes: int.parse(_durationController.text.trim()),
        priceCents: price,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        isActive: true,
      );
      final id = await _repo.create(businessId, service);
      if (!mounted) return;
      final returnPath = GoRouterState.of(
        context,
      ).uri.queryParameters['return'];
      if (returnPath != null && returnPath.isNotEmpty) {
        context.go(returnPath);
      } else {
        context.go('/services/$id');
      }
    } catch (e) {
      setState(() {
        _error = 'Unable to save service.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Add service',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Add service',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Service name'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (cents, optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isValid && !_isLoading
                    ? () => _save(profile.businessId)
                    : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save service'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _isLoading ? null : () => context.go('/services'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}
