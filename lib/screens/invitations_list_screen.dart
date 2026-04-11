import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/invitation.dart';
import '../data/repos/invitation_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class InvitationsListScreen extends StatefulWidget {
  const InvitationsListScreen({super.key});

  @override
  State<InvitationsListScreen> createState() => _InvitationsListScreenState();
}

class _InvitationsListScreenState extends State<InvitationsListScreen> {
  final _repo = InvitationRepository();
  String _filter = 'All';

  Future<List<Invitation>> _load(String businessId) =>
      _repo.list(businessId);

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
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Invitations',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Invitations',
          subtitle: 'Invite-only booking for your clients',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                children: ['All', 'Pending', 'Accepted', 'Revoked'].map((f) {
                  return ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: FutureBuilder<List<Invitation>>(
                  future: _load(profile.businessId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load invitations.',
                          style: AppTextStyles.bodyMuted,
                        ),
                      );
                    }
                    var items = snapshot.data ?? [];
                    if (_filter == 'Pending') {
                      items = items
                          .where((i) =>
                              i.status == InvitationStatus.pending &&
                              !i.isExpired)
                          .toList();
                    } else if (_filter == 'Accepted') {
                      items = items
                          .where(
                              (i) => i.status == InvitationStatus.accepted)
                          .toList();
                    } else if (_filter == 'Revoked') {
                      items = items
                          .where((i) =>
                              i.status == InvitationStatus.revoked ||
                              i.isExpired)
                          .toList();
                    }
                    if (items.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No invitations yet.',
                            style: AppTextStyles.bodyMuted,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () =>
                                context.go('/invitations/new'),
                            child: const Text('Send invitation'),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final inv = items[index];
                        final label = _statusLabel(inv);
                        final color = _statusColor(inv);
                        return ListTile(
                          title: Text(inv.clientName),
                          subtitle: Text(
                            inv.clientEmail,
                            style: AppTextStyles.bodyMuted,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          onTap: () =>
                              context.go('/invitations/${inv.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.go('/invitations/new'),
                child: const Text('Send invitation'),
              ),
            ],
          ),
        );
      },
    );
  }
}
