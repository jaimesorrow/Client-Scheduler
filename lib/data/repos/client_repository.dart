import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientRepository {
  final FirebaseFirestore _firestore;

  ClientRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String businessId) =>
      _firestore.collection('businesses').doc(businessId).collection('clients');

  Future<List<Client>> list(
    String businessId, {
    bool includeArchived = false,
  }) async {
    Query<Map<String, dynamic>> q = _col(businessId).orderBy('fullName');
    if (!includeArchived) {
      q = q.where('isArchived', isEqualTo: false);
    }
    final snap = await q.get();
    return snap.docs.map((d) => Client.fromMap(d.id, d.data())).toList();
  }

  Future<List<Client>> listArchived(String businessId) async {
    final snap = await _col(
      businessId,
    ).where('isArchived', isEqualTo: true).orderBy('fullName').get();
    return snap.docs.map((d) => Client.fromMap(d.id, d.data())).toList();
  }

  Future<Client?> get(String businessId, String clientId) async {
    final doc = await _col(businessId).doc(clientId).get();
    if (!doc.exists) return null;
    return Client.fromMap(doc.id, doc.data()!);
  }

  Future<String> create(String businessId, Client client) async {
    final doc = await _col(businessId).add({
      ...client.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(String businessId, Client client) async {
    await _col(businessId).doc(client.id).update({
      ...client.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> archive(
    String businessId,
    String clientId, {
    required bool archived,
  }) async {
    await _col(businessId).doc(clientId).update({
      'isArchived': archived,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
