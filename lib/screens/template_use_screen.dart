// lib/screens/template_use_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/appointment_draft_provider.dart';
import '../data/repos/template_repository.dart';
import '../data/repos/service_repository.dart';
import '../data/models/template.dart';
import '../data/models/service.dart';
import '../theme/tokens.dart';
import '../widgets/screen_scaffold.dart';
import '../utils/appointment_display.dart';

class TemplateUseScreen extends StatefulWidget {
  const TemplateUseScreen({super.key});

  @override
  State<TemplateUseScreen> createState() => _TemplateUseScreenState();
}

class _TemplateUseScreenState extends State<TemplateUseScreen> {
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

  void _startBooking(BuildContext context, List<Service> services) {
    context.read<AppointmentDraftProvider>().setServices(services);
    if (!mounted) return;
    context.go('/appointments/new/client');
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
            title: 'Use Template',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return FutureBuilder<(Template, List<Service>)>(
          future: _load(profile.businessId, templateId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ScreenScaffold(
                title: 'Use Template',
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return ScreenScaffold(
                title: 'Use Template',
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
            final totalPrice = services.fold(
              0,
              (sum, s) => sum + (s.priceCents ?? 0),
            );

            return ScreenScaffold(
              title: 'Use Template',
              subtitle: template.name,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.card),
                                  ),
                                  child: const Icon(
                                    Icons.layers_outlined,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    template.name,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (services.isEmpty)
                              Text(
                                'No services in this template.',
                                style: AppTextStyles.bodyMuted,
                              )
                            else
                              ...services.map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.accent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: AppTextStyles.body,
                                        ),
                                      ),
                                      Text(
                                        '${formatDuration(s.durationMinutes)} · ${formatPrice(s.priceCents)}',
                                        style: AppTextStyles.bodyMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const Divider(height: AppSpacing.xl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${formatDuration(totalDuration)} · ${formatPrice(totalPrice)}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (template.defaultNotes != null &&
                        template.defaultNotes!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
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

                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'This template will pre-select the services above. You\'ll still choose the client and time.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _startBooking(context, services),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Start Booking'),
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
