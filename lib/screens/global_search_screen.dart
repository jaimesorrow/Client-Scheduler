// lib/screens/global_search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/user_profile_provider.dart';
import '../data/models/client.dart';
import '../data/models/service.dart';
import '../data/repos/client_repository.dart';
import '../data/repos/service_repository.dart';
import '../theme/tokens.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  final _clientRepo = ClientRepository();
  final _serviceRepo = ServiceRepository();
  Timer? _debounce;

  List<Client> _allClients = [];
  List<Service> _allServices = [];
  List<Client> _filteredClients = [];
  List<Service> _filteredServices = [];

  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final profile =
        context.read<UserProfileProvider>().profile;
    final businessId = profile?.businessId;
    if (businessId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final clients = await _clientRepo.list(businessId);
      final services = await _serviceRepo.list(businessId);
      setState(() {
        _allClients = clients;
        _allServices = services;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = value.trim().toLowerCase();
      setState(() {
        _query = q;
        if (q.isEmpty) {
          _filteredClients = [];
          _filteredServices = [];
        } else {
          _filteredClients = _allClients
              .where((c) => c.fullName.toLowerCase().contains(q))
              .toList();
          _filteredServices = _allServices
              .where((s) => s.name.toLowerCase().contains(q))
              .toList();
        }
      });
    });
  }

  bool get _hasResults =>
      _filteredClients.isNotEmpty || _filteredServices.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search clients, services…',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.muted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.muted),
                                onPressed: () {
                                  _searchController.clear();
                                  _onQueryChanged('');
                                },
                              )
                            : null,
                      ),
                      onChanged: _onQueryChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Body
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_query.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Start typing to search.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                )
              else if (!_hasResults)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No results found.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      // Clients section
                      if (_filteredClients.isNotEmpty) ...[
                        _SectionHeader(label: 'Clients'),
                        ..._filteredClients.map(
                          (c) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.accent.withOpacity(0.15),
                              child: Text(
                                c.fullName.isNotEmpty
                                    ? c.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(c.fullName, style: AppTextStyles.body),
                            subtitle: c.email != null
                                ? Text(c.email!, style: AppTextStyles.bodyMuted)
                                : null,
                            onTap: () => context.go('/clients/${c.id}'),
                          ),
                        ),
                      ],

                      // Services section
                      if (_filteredServices.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _SectionHeader(label: 'Services'),
                        ..._filteredServices.map(
                          (s) => ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.info,
                              child: Icon(Icons.design_services,
                                  color: Colors.white, size: 18),
                            ),
                            title: Text(s.name, style: AppTextStyles.body),
                            subtitle: Text(
                              '${s.durationMinutes} min'
                              '${s.priceCents != null ? ' · \$${(s.priceCents! / 100).toStringAsFixed(2)}' : ''}',
                              style: AppTextStyles.bodyMuted,
                            ),
                            onTap: () => context.go('/services/${s.id}'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
