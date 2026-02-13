import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/client.dart';
import '../data/repos/client_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({super.key});

  Future<Client?> _load(String businessId, String id) {
    return ClientRepository().get(businessId, id);
  }

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Client',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Client',
          child: FutureBuilder<Client?>(
            future: _load(profile.businessId, id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final client = snapshot.data;
              if (client == null) {
                return const Text('Client not found.', style: AppTextStyles.bodyMuted);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.fullName, style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      if (client.phone != null) ...[
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Call'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      if (client.email != null) ...[
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Email'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Notes', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text(client.notes ?? 'No notes yet.', style: AppTextStyles.bodyMuted),
                  const SizedBox(height: AppSpacing.lg),
                  Text('History', style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('No appointments yet.', style: AppTextStyles.bodyMuted),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.go('/appointments/new/client'),
                    child: const Text('Book appointment'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => context.go('/clients/$id/edit'),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => context.go('/clients/$id/archive'),
                    child: Text(client.isArchived ? 'Restore client' : 'Archive client'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
