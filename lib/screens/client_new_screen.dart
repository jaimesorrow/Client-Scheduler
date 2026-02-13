import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/client.dart';
import '../data/repos/client_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ClientNewScreen extends StatefulWidget {
  const ClientNewScreen({super.key});

  @override
  State<ClientNewScreen> createState() => _ClientNewScreenState();
}

class _ClientNewScreenState extends State<ClientNewScreen> {
  final _repo = ClientRepository();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isVip = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final nameOk = _nameController.text.trim().isNotEmpty;
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final phoneOk =
        phone.isEmpty || RegExp(r'^[0-9+()\-\s]{7,}$').hasMatch(phone);
    final emailOk =
        email.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return nameOk && phoneOk && emailOk;
  }

  Future<void> _save(String businessId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tags = _isVip ? ['VIP'] : <String>[];
      final client = Client(
        id: '',
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: tags,
        isArchived: false,
      );
      final id = await _repo.create(businessId, client);
      if (!mounted) return;
      final returnPath = GoRouterState.of(
        context,
      ).uri.queryParameters['return'];
      if (returnPath != null && returnPath.isNotEmpty) {
        context.go(returnPath);
      } else {
        context.go('/clients/$id');
      }
    } catch (e) {
      setState(() {
        _error = 'Unable to save client.';
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
            title: 'Add client',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Add client',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                value: _isVip,
                onChanged: _isLoading
                    ? null
                    : (val) => setState(() => _isVip = val),
                title: const Text('VIP'),
                contentPadding: EdgeInsets.zero,
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
                    : const Text('Save client'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _isLoading ? null : () => context.go('/clients'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}
