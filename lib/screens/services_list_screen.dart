import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/repos/service_repository.dart';
import '../data/models/service.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';
import '../widgets/screen_scaffold.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final _repo = ServiceRepository();
  final _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Service>> _load(String businessId) async {
    if (_filter == 'Archived') {
      return _repo.listArchived(businessId);
    }
    return _repo.list(businessId, includeArchived: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Services',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Services',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search services',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: ['All', 'Archived'].map((f) {
                  final selected = _filter == f;
                  return ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: FutureBuilder<List<Service>>(
                  future: _load(profile.businessId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Unable to load services.', style: AppTextStyles.bodyMuted),
                      );
                    }
                    final query = _searchController.text.trim().toLowerCase();
                    var services = snapshot.data ?? [];
                    if (query.isNotEmpty) {
                      services = services.where((s) => s.name.toLowerCase().contains(query)).toList();
                    }
                    if (services.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No services yet.', style: AppTextStyles.bodyMuted),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () => context.go('/services/new'),
                            child: const Text('Add service'),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final details = '${formatDuration(service.durationMinutes)} · ${formatPrice(service.priceCents)}';
                        return ListTile(
                          title: Text(service.name),
                          subtitle: service.isActive
                              ? Text(details)
                              : Text('Archived · $details'),
                          onTap: () => context.go('/services/${service.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.go('/services/new'),
                child: const Text('Add service'),
              ),
            ],
          ),
        );
      },
    );
  }
}
