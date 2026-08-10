import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/timeoff_block.dart';
import '../data/repos/timeoff_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class AvailabilityBlackoutsScreen extends StatefulWidget {
  const AvailabilityBlackoutsScreen({super.key});

  @override
  State<AvailabilityBlackoutsScreen> createState() =>
      _AvailabilityBlackoutsScreenState();
}

class _AvailabilityBlackoutsScreenState
    extends State<AvailabilityBlackoutsScreen> {
  final _repo = TimeoffRepository();

  Future<List<TimeoffBlock>> _load(String businessId) =>
      _repo.list(businessId);

  Future<void> _delete(String businessId, String id) async {
    await _repo.delete(businessId, id);
    setState(() {});
  }

  String _fmtDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Blackouts',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Blackouts & Time Off',
          subtitle: 'Block dates when you are unavailable',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<TimeoffBlock>>(
                  future: _load(profile.businessId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final blocks = snapshot.data ?? [];
                    if (blocks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.event_busy,
                              size: 48,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Text(
                              'No blackout dates.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: blocks.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final b = blocks[i];
                        final same = _fmtDate(b.startDate) ==
                            _fmtDate(b.endDate);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.event_busy,
                            color: AppColors.warning,
                          ),
                          title: Text(
                            same
                                ? _fmtDate(b.startDate)
                                : '${_fmtDate(b.startDate)} – ${_fmtDate(b.endDate)}',
                          ),
                          subtitle: b.reason != null
                              ? Text(b.reason!, style: AppTextStyles.bodyMuted)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                            ),
                            onPressed: () =>
                                _delete(profile.businessId, b.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () =>
                    context.go('/availability/time-off/new'),
                child: const Text('Add blackout date'),
              ),
            ],
          ),
        );
      },
    );
  }
}
