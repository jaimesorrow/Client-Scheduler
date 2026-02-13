import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/repos/service_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ServiceArchiveScreen extends StatefulWidget {
  const ServiceArchiveScreen({super.key});

  @override
  State<ServiceArchiveScreen> createState() => _ServiceArchiveScreenState();
}

class _ServiceArchiveScreenState extends State<ServiceArchiveScreen> {
  final _repo = ServiceRepository();
  bool _isLoading = false;
  String? _error;

  Future<void> _setArchived(String businessId, String id, bool archived) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _repo.archive(businessId, id, archived: archived);
      if (!mounted) return;
      context.go('/services/$id');
    } catch (e) {
      setState(() {
        _error = 'Unable to update service.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final archived = GoRouterState.of(context).uri.queryParameters['archived'] == 'true';
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Archive service',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: archived ? 'Restore service' : 'Archive service',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                archived
                    ? 'Restore this service so it can be booked again.'
                    : 'Archived services are hidden from booking by default.',
                style: AppTextStyles.body,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _setArchived(profile.businessId, id, !archived),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(archived ? 'Restore service' : 'Archive service'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _isLoading ? null : () => context.go('/services/$id'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}
