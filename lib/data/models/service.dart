class Service {
  final String id;
  final String name;
  final int durationMinutes;
  final int? priceCents;
  final String? description;
  final bool isActive;

  const Service({
    required this.id,
    required this.name,
    required this.durationMinutes,
    this.priceCents,
    this.description,
    this.isActive = true,
  });

  factory Service.fromMap(String id, Map<String, dynamic> data) {
    return Service(
      id: id,
      name: (data['name'] ?? '') as String,
      durationMinutes: (data['durationMinutes'] ?? 0) as int,
      priceCents: data['priceCents'] as int?,
      description: data['description'] as String?,
      isActive: (data['isActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'durationMinutes': durationMinutes,
      'priceCents': priceCents,
      'description': description,
      'isActive': isActive,
    };
  }
}
