import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus { pending, accepted, revoked, expired }

class Invitation {
  final String id;
  final String businessId;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final String? message;
  final List<String> serviceIds;
  final InvitationStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  const Invitation({
    required this.id,
    required this.businessId,
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
    this.message,
    this.serviceIds = const [],
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.acceptedAt,
  });

  bool get isExpired =>
      status == InvitationStatus.pending &&
      DateTime.now().isAfter(expiresAt);

  bool get isValid =>
      status == InvitationStatus.pending && !isExpired;

  factory Invitation.fromMap(String id, Map<String, dynamic> data) {
    InvitationStatus parseStatus(String? s) {
      switch (s) {
        case 'accepted':
          return InvitationStatus.accepted;
        case 'revoked':
          return InvitationStatus.revoked;
        case 'expired':
          return InvitationStatus.expired;
        default:
          return InvitationStatus.pending;
      }
    }

    return Invitation(
      id: id,
      businessId: (data['businessId'] ?? '') as String,
      clientName: (data['clientName'] ?? '') as String,
      clientEmail: (data['clientEmail'] ?? '') as String,
      clientPhone: data['clientPhone'] as String?,
      message: data['message'] as String?,
      serviceIds:
          (data['serviceIds'] as List<dynamic>? ?? []).cast<String>(),
      status: parseStatus(data['status'] as String?),
      expiresAt: data['expiresAt'] is Timestamp
          ? (data['expiresAt'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 7)),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'message': message,
      'serviceIds': serviceIds,
      'status': status.name,
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}
