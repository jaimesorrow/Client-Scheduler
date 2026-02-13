import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String businessId) =>
      _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('services');

  Future<List<Service>> list(
    String businessId, {
    bool includeArchived = false,
  }) async {
    Query<Map<String, dynamic>> q = _col(businessId).orderBy('name');
    if (!includeArchived) {
      q = q.where('isActive', isEqualTo: true);
    }
    final snap = await q.get();
    return snap.docs.map((d) => Service.fromMap(d.id, d.data())).toList();
  }

  Future<List<Service>> listArchived(String businessId) async {
    final snap = await _col(
      businessId,
    ).where('isActive', isEqualTo: false).orderBy('name').get();
    return snap.docs.map((d) => Service.fromMap(d.id, d.data())).toList();
  }

  Future<Service?> get(String businessId, String svcId) async {
    final doc = await _col(businessId).doc(svcId).get();
    if (!doc.exists) return null;
    return Service.fromMap(doc.id, doc.data()!);
  }

  Future<String> create(String businessId, Service service) async {
    final doc = await _col(businessId).add(service.toMap());
    return doc.id;
  }

  Future<void> update(String businessId, Service service) async {
    await _col(businessId).doc(service.id).update(service.toMap());
  }

  Future<void> archive(
    String businessId,
    String svcId, {
    required bool archived,
  }) async {
    await _col(businessId).doc(svcId).update({'isActive': !archived});
  }
}
