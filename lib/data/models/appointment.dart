import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientId;
  final List<String> serviceIds;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String? notes;
  final int? totalDurationMin;
  final int? totalPriceCents;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.serviceIds,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.notes,
    this.totalDurationMin,
    this.totalPriceCents,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    final starts = data['startAt'];
    final ends = data['endAt'];
    if (starts == null || ends == null) {
      throw StateError('Appointment $id missing startAt/endAt');
    }
    return Appointment(
      id: id,
      clientId: (data['clientId'] ?? '') as String,
      serviceIds: (data['serviceIds'] as List<dynamic>? ?? []).cast<String>(),
      startAt: starts is Timestamp ? starts.toDate() : (starts as DateTime),
      endAt: ends is Timestamp ? ends.toDate() : (ends as DateTime),
      status: (data['status'] ?? 'scheduled') as String,
      notes: data['notes'] as String?,
      totalDurationMin: data['totalDurationMin'] as int?,
      totalPriceCents: data['totalPriceCents'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'serviceIds': serviceIds,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'status': status,
      'notes': notes,
      'totalDurationMin': totalDurationMin,
      'totalPriceCents': totalPriceCents,
    };
  }
}
