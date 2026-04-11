import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/invitation.dart';
import '../data/models/service.dart';
import '../data/repos/invitation_repository.dart';
import '../data/repos/service_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class InvitationNewScreen extends StatefulWidget {
  const InvitationNewScreen({super.key});

  @override
  State<InvitationNewScreen> createState() => _InvitationNewScreenState();
}

class _InvitationNewScreenState extends State<InvitationNewScreen> {
  final _invRepo = InvitationRepository();
  final _svcRepo = ServiceRepository();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  final Set<String> _selectedServiceIds = {};
  int _expiryDays = 7;
  bool _isLoading = false;
  String? _error;

  static const _expiryOptions = [3, 7, 14, 30];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return name.isNotEmpty && emailOk && _selectedServiceIds.isNotEmpty;
  }

  Future<void> _send(String businessId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final invitation = Invitation(
        id: '',
        businessId: businessId,
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        clientPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        serviceIds: _selectedServiceIds.toList(),
        status: InvitationStatus.pending,
        expiresAt:
            DateTime.now().add(Duration(days: _expiryDays)),
        createdAt: DateTime.now(),
      );
      final token = await _invRepo.create(invitation);
      if (!mounted) return;
      context.go('/invitations/$token');
    } catch (e) {
      setState(() => _error = 'Unable to send invitation.');
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
            title: 'Send invitation',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Send invitation',
          subtitle: 'Invite a client to book with you',
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Client full name',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Client email'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Client phone (optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text('Services included', style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<List<Service>>(
                  future: _svcRepo.list(profile.businessId),
                  builder: (context, snap) {
                    if (snap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final services = snap.data ?? [];
                    if (services.isEmpty) {
                      return Text(
                        'No active services found. Add services first.',
                        style: AppTextStyles.bodyMuted,
                      );
                    }
                    return Column(
                      children: services.map((svc) {
                        final checked =
                            _selectedServiceIds.contains(svc.id);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(svc.name),
                          subtitle: svc.description != null
                              ? Text(
                                  svc.description!,
                                  style: AppTextStyles.bodyMuted,
                                )
                              : null,
                          onChanged: _isLoading
                              ? null
                              : (val) => setState(() {
                                    if (val == true) {
                                      _selectedServiceIds.add(svc.id);
                                    } else {
                                      _selectedServiceIds
                                          .remove(svc.id);
                                    }
                                  }),
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Invitation expires in',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _expiryOptions.map((days) {
                    return ChoiceChip(
                      label: Text('$days days'),
                      selected: _expiryDays == days,
                      onSelected: _isLoading
                          ? null
                          : (_) =>
                              setState(() => _expiryDays = days),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Personal message (optional)',
                    hintText:
                        'e.g. Looking forward to seeing you again!',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style:
                        const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isValid && !_isLoading
                      ? () => _send(profile.businessId)
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Send invitation'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => context.go('/invitations'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}
