class UserProfile {
  final String uid;
  final String role;
  final String businessId;
  final bool onboardingComplete;

  const UserProfile({
    required this.uid,
    required this.role,
    required this.businessId,
    required this.onboardingComplete,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      role: (data['role'] ?? 'staff') as String,
      businessId: (data['businessId'] ?? '') as String,
      onboardingComplete: (data['onboardingComplete'] ?? false) as bool,
    );
  }
}
