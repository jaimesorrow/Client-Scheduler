// lib/screens/appt_new_service_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/appointment_draft_provider.dart';
import '../data/models/service.dart';
import '../data/repos/service_repository.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';

class ApptNewServiceScreen extends StatefulWidget {
  const ApptNewServiceScreen({super.key});

  @override
  State<ApptNewServiceScreen> createState() => _ApptNewServiceScreenState();
}

class _ApptNewServiceScreenState extends State<ApptNewServiceScreen> {
  final _serviceRepo = ServiceRepository();

  Future<List<Service>>? _future;
  String? _businessId;
  final Set<String> _selectedIds = {};
  List<Service> _loadedServices = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.read<UserProfileProvider>().profile;
    if (profile != null && profile.businessId != _businessId) {
      _businessId = profile.businessId;
      _future = _serviceRepo.list(profile.businessId);
    }
    // Pre-fill selections from draft
    final draft = context.read<AppointmentDraftProvider>();
    if (_selectedIds.isEmpty && draft.serviceIds.isNotEmpty) {
      _selectedIds.addAll(draft.serviceIds);
    }
  }

  List<Service> get _selectedServices =>
      _loadedServices.where((s) => _selectedIds.contains(s.id)).toList();

  int get _totalDuration =>
      _selectedServices.fold(0, (sum, s) => sum + s.durationMinutes);

  int get _totalPrice =>
      _selectedServices.fold(0, (sum, s) => sum + (s.priceCents ?? 0));

  void _onContinue(BuildContext context) {
    context
        .read<AppointmentDraftProvider>()
        .setServices(_selectedServices);
    context.go('/appointments/new/time');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            foregroundColor: AppColors.ink,
            leading: BackButton(
              onPressed: () => context.go('/appointments/new/client'),
            ),
            title: const Text(
              'New Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 2 of 4 — Select services',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Services list
                  Expanded(
                    child: FutureBuilder<List<Service>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Unable to load services.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        _loadedServices = snapshot.data!;
                        if (_loadedServices.isEmpty) {
                          return const Center(
                            child: Text(
                              'No active services. Add services first.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _loadedServices.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final svc = _loadedServices[i];
                            final isSelected = _selectedIds.contains(svc.id);
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: isSelected,
                              onChanged: (_) => setState(() {
                                if (isSelected) {
                                  _selectedIds.remove(svc.id);
                                } else {
                                  _selectedIds.add(svc.id);
                                }
                              }),
                              title: Text(svc.name),
                              subtitle: Text(
                                '${formatDuration(svc.durationMinutes)}'
                                '${svc.priceCents != null ? '  ·  ${formatPrice(svc.priceCents)}' : ''}',
                                style: AppTextStyles.bodyMuted,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.accent,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Running total — only show once services have loaded
                  if (_selectedIds.isNotEmpty && _loadedServices.isNotEmpty) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${formatDuration(_totalDuration)}'
                            '${_totalPrice > 0 ? '  ·  ${formatPrice(_totalPrice)}' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedIds.isEmpty
                          ? null
                          : () => _onContinue(context),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
