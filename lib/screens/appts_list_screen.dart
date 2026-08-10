// lib/screens/appts_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointment_repository.dart';
import '../data/repos/client_repository.dart';
import '../data/repos/service_repository.dart';
import '../theme/tokens.dart';
import '../utils/appointment_display.dart';
import '../widgets/screen_scaffold.dart';

typedef _ListData
    = (List<Appointment>, Map<String, String>, Map<String, String>);

String _fmtDate(DateTime d) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

String _fmtTime(DateTime d) {
  final h = d.hour;
  final period = h < 12 ? 'AM' : 'PM';
  final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$displayH:${d.minute.toString().padLeft(2, '0')} $period';
}

Widget _statusBadge(String status) {
  final (color, label) = switch (status) {
    'scheduled' => (AppColors.info, 'Scheduled'),
    'completed' => (AppColors.success, 'Completed'),
    'cancelled' => (AppColors.muted, 'Cancelled'),
    'no_show' => (AppColors.warning, 'No Show'),
    'pending_client' => (AppColors.warning, 'Pending'),
    _ => (AppColors.muted, status),
  };
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

class ApptsListScreen extends StatefulWidget {
  const ApptsListScreen({super.key});

  @override
  State<ApptsListScreen> createState() => _ApptsListScreenState();
}

class _ApptsListScreenState extends State<ApptsListScreen> {
  final _apptRepo = AppointmentRepository();
  final _clientRepo = ClientRepository();
  final _serviceRepo = ServiceRepository();

  Future<_ListData>? _future;
  String? _businessId;
  String _filter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.read<UserProfileProvider>().profile;
    if (profile != null && profile.businessId != _businessId) {
      _businessId = profile.businessId;
      _future = _load(profile.businessId);
    }
  }

  Future<_ListData> _load(String businessId) async {
    final apptsFut = _apptRepo.list(businessId);
    final clientsFut = _clientRepo.list(businessId, includeArchived: true);
    final servicesFut = _serviceRepo.list(businessId, includeArchived: true);

    final appts = await apptsFut;
    final clients = await clientsFut;
    final services = await servicesFut;

    appts.sort((a, b) => b.startAt.compareTo(a.startAt));

    final clientMap = {for (final c in clients) c.id: c.fullName};
    final serviceMap = {for (final s in services) s.id: s.name};

    return (appts, clientMap, serviceMap);
  }

  List<Appointment> _applyFilter(List<Appointment> appts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_filter) {
      case 'Today':
        return appts.where((a) {
          final d = DateTime(a.startAt.year, a.startAt.month, a.startAt.day);
          return d == today;
        }).toList();
      case 'Upcoming':
        return appts.where((a) {
          final d = DateTime(a.startAt.year, a.startAt.month, a.startAt.day);
          return d.isAfter(today) &&
              (a.status == 'scheduled' || a.status == 'pending_client');
        }).toList();
      case 'Completed':
        return appts.where((a) => a.status == 'completed').toList();
      default:
        return appts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        if (profileProvider.profile == null) {
          return const ScreenScaffold(
            title: 'Appointments',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ScreenScaffold(
          title: 'Appointments',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Today', 'Upcoming', 'Completed']
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Appointment list
              Expanded(
                child: FutureBuilder<_ListData>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load appointments.',
                          style: AppTextStyles.bodyMuted,
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final (appts, clientMap, serviceMap) = snapshot.data!;
                    final filtered = _applyFilter(appts);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _filter == 'All'
                                  ? 'No appointments yet.'
                                  : 'No $_filter appointments.',
                              style: AppTextStyles.bodyMuted,
                            ),
                            if (_filter == 'All') ...[
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton(
                                onPressed: () => context.go(
                                  '/appointments/new/client',
                                ),
                                child: const Text('Book first appointment'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final appt = filtered[i];
                        final clientName =
                            clientMap[appt.clientId] ?? 'Unknown Client';
                        final svcNames = appt.serviceIds
                            .map((id) => serviceMap[id] ?? '?')
                            .toList();
                        return InkWell(
                          onTap: () =>
                              context.go('/appointments/${appt.id}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        clientName,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _statusBadge(appt.status),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  summarizeServices(svcNames),
                                  style: AppTextStyles.bodyMuted,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${_fmtDate(appt.startAt)}  ·  '
                                  '${_fmtTime(appt.startAt)}',
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/appointments/new/client'),
                  child: const Text('New appointment'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
