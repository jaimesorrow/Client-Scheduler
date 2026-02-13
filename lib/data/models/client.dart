class Client {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final String? notes;
  final List<String> tags;
  final bool isArchived;

  const Client({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.notes,
    this.tags = const [],
    this.isArchived = false,
  });

  factory Client.fromMap(String id, Map<String, dynamic> data) {
    return Client(
      id: id,
      fullName: (data['fullName'] ?? '') as String,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      notes: data['notes'] as String?,
      tags: (data['tags'] as List<dynamic>? ?? []).cast<String>(),
      isArchived: (data['isArchived'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'notes': notes,
      'tags': tags,
      'isArchived': isArchived,
    };
  }
}
