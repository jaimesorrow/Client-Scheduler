import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation.dart';

/// Invitations are stored in a root-level `invites` collection so clients can
/// look them up by token without knowing the business ID.
class InvitationRepository {
  final FirebaseFirestore _firestore;

  InvitationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('invites');

  /// Returns all invitations for a business, newest first.
  Future<List<Invitation>> list(String businessId) async {
    final snap = await _col
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => Invitation.fromMap(d.id, d.data()))
        .toList();
  }

  /// Fetches a single invitation by its token (document ID).
  Future<Invitation?> get(String token) async {
    final doc = await _col.doc(token).get();
    if (!doc.exists) return null;
    return Invitation.fromMap(doc.id, doc.data()!);
  }

  /// Creates a new invitation and returns the generated token.
  Future<String> create(Invitation invitation) async {
    final doc = _col.doc();
    await doc.set({
      ...invitation.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Revokes a pending invitation.
  Future<void> revoke(String token) async {
    await _col.doc(token).update({
      'status': 'revoked',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks an invitation as accepted (called from the client booking page).
  Future<void> accept(String token) async {
    await _col.doc(token).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
