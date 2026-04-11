import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/invitation.dart';
import '../data/models/service.dart';
import '../data/repos/invitation_repository.dart';
import '../data/repos/service_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class InvitationDetailScreen extends StatefulWidget {
  const InvitationDetailScreen({super.key});

  @override
  State<InvitationDetailScreen> createState() =>
      _InvitationDetailScreenState();
}

class _InvitationDetailScreenState
    extends State<InvitationDetailScreen> {
  final _invRepo = InvitationRepository();
  final _svcRepo = ServiceRepository();
  bool _isRevoking = false;
  String? _error;

  Future<(Invitation?, List<Service>)> _load(
    String token,
    String businessId,
  ) async {
    final inv = await _invRepo.get(token);
    if (inv == null) return (null, <Service>[]);
    final services = await Future.wait(
      inv.serviceIds.map((id) => _svcRepo.get(businessId, id)),
    );
    return (inv, services.whereType<Service>().toList());
  }

  Future<void> _revoke(String token) async {
    setState(() {
      _isRevoking = true;
      _error = null;
    });
    try {
      await _invRepo.revoke(token);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      setState(() => _error = 'Unable to revoke invitation.');
    } finally {
      if (mounted) setState(() => _isRevoking = false);
    }
  }

  void _copyLink(BuildContext context, String token) {
    final link = 'book/$token';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied to clipboard')),
    );
  }

  Color _statusColor(Invitation inv) {
    if (inv.status == InvitationStatus.accepted) return AppColors.success;
    if (inv.status == InvitationStatus.revoked) return AppColors.danger;
    if (inv.isExpired) return AppColors.warning;
    return AppColors.info;
  }

  String _statusLabel(Invitation inv) {
    if (inv.status == InvitationStatus.accepted) return 'Accepted';
    if (inv.status == InvitationStatus.revoked) return 'Revoked';
    if (inv.isExpired) return 'Expired';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final token =
        GoRouterState.of(context).pathParameters['token'] ?? '';
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Invitation',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Invitation',
          child: FutureBuilder<(Invitation?, List<Service>)>(
            future: _load(token, profile.businessId),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final inv = snapshot.data?.$1;
              final services = snapshot.data?.$2 ?? [];
              if (inv == null) {
                return const Text(
                  'Invitation not found.',
                  style: AppTextStyles.bodyMuted,
                );
              }
              final statusLabel = _statusLabel(inv);
              final statusColor = _statusColor(inv);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Client info
                  Text(inv.clientName, style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.sm),
                  Text(inv.clientEmail, style: AppTextStyles.bodyMuted),
                  if (inv.clientPhone != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      inv.clientPhone!,
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  // Services
                  const Text(
                    'Invited for',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (services.isEmpty)
                    const Text(
                      'Services no longer available.',
                      style: AppTextStyles.bodyMuted,
                    )
                  else
                    ...services.map(
                      (svc) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              svc.name,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  // Personal message
                  if (inv.message != null) ...[
                    const Text(
                      'Message',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      inv.message!,
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  // Expiry
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        inv.status == InvitationStatus.accepted
                            ? 'Accepted ${_formatDate(inv.acceptedAt!)}'
                            : inv.isExpired
                                ? 'Expired ${_formatDate(inv.expiresAt)}'
                                : 'Expires ${_formatDate(inv.expiresAt)}',
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Invite link
                  if (inv.isValid) ...[
                    const Text(
                      'Invite link',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius:
                            BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'book/${inv.id}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () =>
                                _copyLink(context, inv.id),
                            tooltip: 'Copy link',
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style:
                          const TextStyle(color: AppColors.danger),
                    ),
                  ],
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => context.go('/invitations'),
                    child: const Text('Back to invitations'),
                  ),
                  if (inv.isValid) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _isRevoking
                          ? null
                          : () => _showRevokeConfirm(context, inv.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(
                          color: AppColors.danger,
                        ),
                      ),
                      child: _isRevoking
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Revoke invitation'),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showRevokeConfirm(BuildContext context, String token) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke invitation?'),
        content: const Text(
          'The client will no longer be able to use this invite link to book.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _revoke(token);
    });
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
