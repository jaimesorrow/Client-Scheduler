class BusinessSettings {
  final String businessId;
  final bool onboardingComplete;
  final String? businessName;
  final String timezone;
  final Map<String, bool> workingDays;
  final Map<String, Map<String, String>> workingHours;

  static const _defaultDays = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  static const _defaultHours = {
    'Mon': {'open': '09:00', 'close': '17:00'},
    'Tue': {'open': '09:00', 'close': '17:00'},
    'Wed': {'open': '09:00', 'close': '17:00'},
    'Thu': {'open': '09:00', 'close': '17:00'},
    'Fri': {'open': '09:00', 'close': '17:00'},
    'Sat': {'open': '09:00', 'close': '17:00'},
    'Sun': {'open': '09:00', 'close': '17:00'},
  };

  const BusinessSettings({
    required this.businessId,
    required this.onboardingComplete,
    this.businessName,
    this.timezone = 'America/New_York',
    this.workingDays = const {
      'Mon': true,
      'Tue': true,
      'Wed': true,
      'Thu': true,
      'Fri': true,
      'Sat': false,
      'Sun': false,
    },
    this.workingHours = const {
      'Mon': {'open': '09:00', 'close': '17:00'},
      'Tue': {'open': '09:00', 'close': '17:00'},
      'Wed': {'open': '09:00', 'close': '17:00'},
      'Thu': {'open': '09:00', 'close': '17:00'},
      'Fri': {'open': '09:00', 'close': '17:00'},
      'Sat': {'open': '09:00', 'close': '17:00'},
      'Sun': {'open': '09:00', 'close': '17:00'},
    },
  });

  factory BusinessSettings.fromMap(
    String businessId,
    Map<String, dynamic> data,
  ) {
    Map<String, bool> parseDays(dynamic raw) {
      if (raw is Map) {
        return {
          for (final e in raw.entries)
            e.key as String: (e.value ?? false) as bool,
        };
      }
      return Map<String, bool>.from(_defaultDays);
    }

    Map<String, Map<String, String>> parseHours(dynamic raw) {
      if (raw is Map) {
        return {
          for (final e in raw.entries)
            e.key as String: {
              'open': ((e.value as Map)['open'] ?? '09:00') as String,
              'close': ((e.value as Map)['close'] ?? '17:00') as String,
            },
        };
      }
      return {
        for (final e in _defaultHours.entries)
          e.key: Map<String, String>.from(e.value),
      };
    }

    return BusinessSettings(
      businessId: businessId,
      onboardingComplete: (data['onboardingComplete'] ?? false) as bool,
      businessName: data['businessName'] as String?,
      timezone: (data['timezone'] ?? 'America/New_York') as String,
      workingDays: parseDays(data['workingDays']),
      workingHours: parseHours(data['workingHours']),
    );
  }

  Map<String, dynamic> toMap() => {
        'onboardingComplete': onboardingComplete,
        'businessName': businessName,
        'timezone': timezone,
        'workingDays': workingDays,
        'workingHours': workingHours,
      };
}
