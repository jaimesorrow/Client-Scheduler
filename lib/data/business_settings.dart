class BusinessSettings {
  final String businessId;
  final bool onboardingComplete;

  const BusinessSettings({
    required this.businessId,
    required this.onboardingComplete,
  });

  factory BusinessSettings.fromMap(
    String businessId,
    Map<String, dynamic> data,
  ) {
    return BusinessSettings(
      businessId: businessId,
      onboardingComplete: (data['onboardingComplete'] ?? false) as bool,
    );
  }
}
