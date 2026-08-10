// lib/screens/template_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/repos/template_repository.dart';
import '../data/repos/service_repository.dart';
import '../data/models/template.dart';
import '../data/models/service.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';
import '../utils/appointment_display.dart';

class TemplateDetailScreen extends StatefulWidget {
  const TemplateDetailScreen({super.key});

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  final _templateRepo = TemplateRepository();
  final _serviceRepo = ServiceRepository();

  Future<(Template, List<Service>)> _load(
    String businessId,
    String templateId,
  ) async {
    final template = await _templateRepo.get(businessId, templateId);
    if (template == null) throw Exception('Template not found');

    final fetched = await Future.wait(
      template.serviceIds.map((id) => _serviceRepo.get(businessId, id)),
    );
    return (template, fetched.whereType<Service>().toList());
  }

  Future<void> _delete(
    BuildContext context,
    String businessId,
    String templateId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text(
          'Are you sure you want to delete this template? This action cannot be undone.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _templateRepo.delete(businessId, templateId);
    if (!mounted) return;
    context.go('/templates');
  }

  @override
  Widget build(BuildContext context) {
    final templateId =
        GoRouterState.of(context).pathParameters['id'] ?? '';

    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null) {
          return const ScreenScaffold(
            title: 'Template',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return FutureBuilder<(Template, List<Service>)>(
          future: _load(profile.businessId, templateId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ScreenScaffold(
                title: 'Template',
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return ScreenScaffold(
                title: 'Template',
                child: Center(
                  child: Text(
                    'Unable to load template.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ),
              );
            }

            final (template, services) = snapshot.data!;
            final totalDuration = services.fold(
              0,
              (sum, s) => sum + s.durationMinutes,
            );
            final totalPrice = template.defaultPriceCents ??
                services.fold(0, (sum, s) => sum + (s.priceCents ?? 0));

            return ScreenScaffold(
              title: template.name,
              subtitle: 'Template details',
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Services section
                    Text(
                      'Services',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (services.isEmpty)
                      Text(
                        'No services linked.',
                        style: AppTextStyles.bodyMuted,
                      )
                    else
                      ...services.map(
                        (s) => Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.card),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.name,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatDuration(s.durationMinutes),
                                      style: AppTextStyles.bodyMuted,
                                    ),
                                    Text(
                                      formatPrice(s.priceCents),
                                      style: AppTextStyles.bodyMuted,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),

                    // Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Duration', style: AppTextStyles.bodyMuted),
                        Text(
                          template.defaultDurationMinutes != null
                              ? formatDuration(
                                  template.defaultDurationMinutes!,
                                )
                              : formatDuration(totalDuration),
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price', style: AppTextStyles.bodyMuted),
                        Text(
                          formatPrice(totalPrice),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),

                    // Default notes
                    if (template.defaultNotes != null &&
                        template.defaultNotes!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Default Notes',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                        ),
                        child: Text(
                          template.defaultNotes!,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.go('/templates/$templateId/use'),
                        icon: const Icon(Icons.play_arrow_outlined),
                        label: const Text('Use Template'),
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
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.go('/templates/$templateId/edit'),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.card),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _delete(
                              context,
                              profile.businessId,
                              templateId,
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: AppColors.danger),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.card),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
