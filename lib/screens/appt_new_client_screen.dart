// lib/screens/appt_new_client_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/appointment_draft_provider.dart';
import '../data/models/client.dart';
import '../data/repos/client_repository.dart';
import '../theme/tokens.dart';

class ApptNewClientScreen extends StatefulWidget {
  const ApptNewClientScreen({super.key});

  @override
  State<ApptNewClientScreen> createState() => _ApptNewClientScreenState();
}

class _ApptNewClientScreenState extends State<ApptNewClientScreen> {
  final _clientRepo = ClientRepository();
  final _searchController = TextEditingController();

  Future<List<Client>>? _future;
  String? _businessId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.read<UserProfileProvider>().profile;
    if (profile != null && profile.businessId != _businessId) {
      _businessId = profile.businessId;
      _future = _clientRepo.list(profile.businessId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectClient(BuildContext context, Client client) {
    context.read<AppointmentDraftProvider>().setClient(client.id, client.fullName);
    context.go('/appointments/new/service');
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
              onPressed: () {
                context.read<AppointmentDraftProvider>().clear();
                context.go('/appointments');
              },
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
                    'Step 1 of 4 — Select a client',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search clients',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Client list
                  Expanded(
                    child: FutureBuilder<List<Client>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Unable to load clients.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final query =
                            _searchController.text.trim().toLowerCase();
                        final clients = snapshot.data!
                            .where(
                              (c) => query.isEmpty ||
                                  c.fullName.toLowerCase().contains(query),
                            )
                            .toList();

                        if (clients.isEmpty) {
                          return Center(
                            child: Text(
                              query.isEmpty
                                  ? 'No clients yet.'
                                  : 'No clients match "$query".',
                              style: AppTextStyles.bodyMuted,
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: clients.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final client = clients[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(client.fullName),
                              subtitle: client.phone != null
                                  ? Text(
                                      client.phone!,
                                      style: AppTextStyles.bodyMuted,
                                    )
                                  : null,
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: AppColors.muted,
                              ),
                              onTap: () => _selectClient(context, client),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('New client'),
                      onPressed: () => context.go(
                        '/clients/new?return=/appointments/new/service',
                      ),
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
