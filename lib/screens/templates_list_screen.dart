// lib/screens/templates_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/repos/template_repository.dart';
import '../data/models/template.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';

class TemplatesListScreen extends StatefulWidget {
  const TemplatesListScreen({super.key});

  @override
  State<TemplatesListScreen> createState() => _TemplatesListScreenState();
}

class _TemplatesListScreenState extends State<TemplatesListScreen> {
  final _repo = TemplateRepository();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Templates',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Templates',
          subtitle: 'Reusable booking templates',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<Template>>(
                  future: _repo.list(profile.businessId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load templates.',
                          style: AppTextStyles.bodyMuted,
                        ),
                      );
                    }
                    final templates = snapshot.data ?? [];
                    if (templates.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.layers_outlined,
                              size: 48,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const Text(
                              'No templates yet.',
                              style: AppTextStyles.bodyMuted,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Create a template to speed up booking.',
                              style: AppTextStyles.bodyMuted,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/templates/new'),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Template'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.card,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: templates.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: AppSpacing.xs,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadii.card),
                            ),
                            child: const Icon(
                              Icons.layers_outlined,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            template.name,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${template.serviceIds.length} service${template.serviceIds.length == 1 ? '' : 's'}',
                            style: AppTextStyles.bodyMuted,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                          ),
                          onTap: () =>
                              context.go('/templates/${template.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/templates/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('New Template'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
