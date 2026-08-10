// lib/screens/template_edit_screen.dart
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

class TemplateEditScreen extends StatefulWidget {
  const TemplateEditScreen({super.key});

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  final _templateRepo = TemplateRepository();
  final _serviceRepo = ServiceRepository();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Service> _allServices = [];
  Set<String> _selectedServiceIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final templateId =
        GoRouterState.of(context).pathParameters['id'];
    final profile = context.read<UserProfileProvider>().profile;
    if (profile == null) return;

    final services = await _serviceRepo.list(profile.businessId);

    if (templateId != null && templateId.isNotEmpty) {
      final template =
          await _templateRepo.get(profile.businessId, templateId);
      if (template != null) {
        _nameController.text = template.name;
        _notesController.text = template.defaultNotes ?? '';
        _selectedServiceIds = template.serviceIds.toSet();
      }
    }

    if (!mounted) return;
    setState(() {
      _allServices = services;
      _isLoading = false;
    });
  }

  Future<void> _save(String businessId, String? templateId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final selectedServices = _allServices
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();
    final totalDuration = selectedServices.fold(
      0,
      (sum, s) => sum + s.durationMinutes,
    );
    final totalPrice = selectedServices.fold(
      0,
      (sum, s) => sum + (s.priceCents ?? 0),
    );
    final notesValue = _notesController.text.trim();

    final template = Template(
      id: templateId ?? '',
      name: _nameController.text.trim(),
      serviceIds: _selectedServiceIds.toList(),
      defaultNotes: notesValue.isEmpty ? null : notesValue,
      defaultDurationMinutes: totalDuration > 0 ? totalDuration : null,
      defaultPriceCents: totalPrice > 0 ? totalPrice : null,
    );

    try {
      if (templateId == null || templateId.isEmpty) {
        await _templateRepo.create(businessId, template);
        if (!mounted) return;
        context.go('/templates');
      } else {
        await _templateRepo.update(businessId, template);
        if (!mounted) return;
        context.go('/templates/$templateId');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save template.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateId =
        GoRouterState.of(context).pathParameters['id'];
    final isCreate = templateId == null || templateId.isEmpty;

    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        if (profile == null || _isLoading) {
          return ScreenScaffold(
            title: isCreate ? 'New Template' : 'Edit Template',
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return ScreenScaffold(
          title: isCreate ? 'New Template' : 'Edit Template',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Template Name *',
                            hintText: 'e.g. Full Color Treatment',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Services
                        Text(
                          'Services',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Select services to include in this template',
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_allServices.isEmpty)
                          Text(
                            'No active services available.',
                            style: AppTextStyles.bodyMuted,
                          )
                        else
                          ..._allServices.map((service) {
                            final selected =
                                _selectedServiceIds.contains(service.id);
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.divider,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.card),
                                color: selected
                                    ? AppColors.accent.withOpacity(0.05)
                                    : null,
                              ),
                              child: CheckboxListTile(
                                value: selected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedServiceIds.add(service.id);
                                    } else {
                                      _selectedServiceIds.remove(service.id);
                                    }
                                  });
                                },
                                title: Text(service.name),
                                subtitle: Text(
                                  '${service.durationMinutes}m · \$${((service.priceCents ?? 0) / 100).toStringAsFixed(2)}',
                                  style: AppTextStyles.bodyMuted,
                                ),
                                activeColor: AppColors.accent,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.card),
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: AppSpacing.xl),

                        // Notes
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Default Notes (optional)',
                            hintText:
                                'Notes pre-filled when this template is used',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _save(profile.businessId, templateId),
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
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isCreate ? 'Create Template' : 'Save Changes',
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}
