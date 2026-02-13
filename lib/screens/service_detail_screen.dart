import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/service.dart';
import '../data/repos/service_repository.dart';
import '../data/user_profile_provider.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';
import '../widgets/screen_scaffold.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  Future<Service?> _load(String businessId, String id) {
    return ServiceRepository().get(businessId, id);
  }

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Service',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Service',
          child: FutureBuilder<Service?>(
            future: _load(profile.businessId, id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final service = snapshot.data;
              if (service == null) {
                return const Text(
                  'Service not found.',
                  style: AppTextStyles.bodyMuted,
                );
              }
              final archived = !service.isActive;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${formatDuration(service.durationMinutes)} · ${formatPrice(service.priceCents)}',
                    style: AppTextStyles.bodyMuted,
                  ),
                  if (service.description != null &&
                      service.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(service.description!, style: AppTextStyles.body),
                  ] else ...[
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'No description.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.go('/services/$id/edit'),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () =>
                        context.go('/services/$id/archive?archived=$archived'),
                    child: Text(
                      service.isActive ? 'Archive service' : 'Restore service',
                    ),
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
