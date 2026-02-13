class Template {
  final String id;
  final String name;
  final List<String> serviceIds;
  final String? defaultNotes;
  final int? defaultDurationMinutes;
  final int? defaultPriceCents;

  const Template({
    required this.id,
    required this.name,
    this.serviceIds = const [],
    this.defaultNotes,
    this.defaultDurationMinutes,
    this.defaultPriceCents,
  });

  factory Template.fromMap(String id, Map<String, dynamic> data) {
    return Template(
      id: id,
      name: (data['name'] ?? '') as String,
      serviceIds: (data['serviceIds'] as List<dynamic>? ?? []).cast<String>(),
      defaultNotes: data['defaultNotes'] as String?,
      defaultDurationMinutes: data['defaultDurationMinutes'] as int?,
      defaultPriceCents: data['defaultPriceCents'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'serviceIds': serviceIds,
      'defaultNotes': defaultNotes,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultPriceCents': defaultPriceCents,
    };
  }
}
