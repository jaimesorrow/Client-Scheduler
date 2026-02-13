import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/repos/client_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ClientArchiveScreen extends StatefulWidget {
  const ClientArchiveScreen({super.key});

  @override
  State<ClientArchiveScreen> createState() => _ClientArchiveScreenState();
}

class _ClientArchiveScreenState extends State<ClientArchiveScreen> {
  final _repo = ClientRepository();
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
      context.go('/clients/$id');
    } catch (e) {
      setState(() {
        _error = 'Unable to update client.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final archived =
        GoRouterState.of(context).uri.queryParameters['archived'] == 'true';
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Archive client',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: archived ? 'Restore client' : 'Archive client',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                archived
                    ? 'Restore this client so they can be booked again.'
                    : 'Archived clients are hidden from booking by default.',
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
                    : Text(archived ? 'Restore client' : 'Archive client'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _isLoading ? null : () => context.go('/clients/$id'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}
