// lib/screens/timeoff_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/timeoff_block.dart';
import '../data/repos/timeoff_repository.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class TimeoffListScreen extends StatefulWidget {
  const TimeoffListScreen({super.key});

  @override
  State<TimeoffListScreen> createState() => _TimeoffListScreenState();
}

class _TimeoffListScreenState extends State<TimeoffListScreen> {
  late Future<List<TimeoffBlock>> _future;
  String _businessId = '';

  @override
  void initState() {
    super.initState();
    _businessId =
        context.read<UserProfileProvider>().profile?.businessId ?? '';
    _loadBlocks();
  }

  void _loadBlocks() {
    _future = TimeoffRepository().list(_businessId);
  }

  Future<void> _delete(String blockId) async {
    try {
      await TimeoffRepository().delete(_businessId, blockId);
      setState(() => _loadBlocks());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete. Please try again.')),
      );
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Time Off',
      subtitle: 'Dates when you are unavailable.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<TimeoffBlock>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load time off blocks.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  );
                }
                final blocks = snapshot.data ?? [];
                if (blocks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.beach_access_outlined,
                          size: 48,
                          color: AppColors.muted,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'No time off blocks yet.',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: blocks.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.divider, height: 1),
                  itemBuilder: (context, i) {
                    final block = blocks[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${_formatDate(block.startDate)} – ${_formatDate(block.endDate)}',
                        style: AppTextStyles.body,
                      ),
                      subtitle: block.reason != null && block.reason!.isNotEmpty
                          ? Text(block.reason!, style: AppTextStyles.bodyMuted)
                          : null,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
                        onPressed: () => _showDeleteDialog(context, block),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.push('/availability/time-off/new');
              setState(() => _loadBlocks());
            },
            child: const Text('Add time off'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, TimeoffBlock block) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove time off?'),
        content: const Text(
          'This block will be removed and clients may be able to book during this period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _delete(block.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
