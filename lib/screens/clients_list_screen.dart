import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/repos/client_repository.dart';
import '../data/models/client.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final _repo = ClientRepository();
  final _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Client>> _load(String businessId) async {
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
            title: 'Clients',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ScreenScaffold(
          title: 'Clients',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search clients',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: ['All', 'VIP', 'Archived'].map((f) {
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
                child: FutureBuilder<List<Client>>(
                  future: _load(profile.businessId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Unable to load clients.', style: AppTextStyles.bodyMuted),
                      );
                    }
                    final query = _searchController.text.trim().toLowerCase();
                    var clients = snapshot.data ?? [];
                    if (_filter == 'VIP') {
                      clients = clients.where((c) => c.tags.map((t) => t.toLowerCase()).contains('vip')).toList();
                    }
                    if (query.isNotEmpty) {
                      clients = clients.where((c) => c.fullName.toLowerCase().contains(query)).toList();
                    }
                    if (clients.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No clients yet.', style: AppTextStyles.bodyMuted),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: () => context.go('/clients/new'),
                            child: const Text('Add client'),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: clients.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ListTile(
                          title: Text(client.fullName),
                          subtitle: client.isArchived ? const Text('Archived') : null,
                          onTap: () => context.go('/clients/${client.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.go('/clients/new'),
                child: const Text('Add client'),
              ),
            ],
          ),
        );
      },
    );
  }
}
