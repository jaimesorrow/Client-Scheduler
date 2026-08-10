import 'package:flutter/material.dart';
import 'business_settings.dart';
import 'business_settings_repository.dart';

class BusinessSettingsProvider extends ChangeNotifier {
  final BusinessSettingsRepository _repo;

  BusinessSettingsProvider({BusinessSettingsRepository? repo})
      : _repo = repo ?? BusinessSettingsRepository();

  BusinessSettings? settings;
  bool isLoading = false;

  Future<void> load(String businessId) async {
    isLoading = true;
    notifyListeners();
    settings = await _repo.getSettings(businessId);
    isLoading = false;
    notifyListeners();
  }

  void markOnboardingComplete() {
    if (settings == null) return;
    settings = BusinessSettings(
      businessId: settings!.businessId,
      onboardingComplete: true,
      businessName: settings!.businessName,
      timezone: settings!.timezone,
      workingDays: settings!.workingDays,
      workingHours: settings!.workingHours,
    );
    notifyListeners();
  }
}
