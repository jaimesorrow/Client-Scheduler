import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String businessId) =>
      _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('appointments');

  Future<List<Appointment>> list(String businessId) async {
    final snap = await _col(
      businessId,
    ).orderBy('startAt', descending: false).get();
    return snap.docs.map((d) => Appointment.fromMap(d.id, d.data())).toList();
  }

  Future<Appointment?> get(String businessId, String appointmentId) async {
    final doc = await _col(businessId).doc(appointmentId).get();
    if (!doc.exists) return null;
    return Appointment.fromMap(doc.id, doc.data()!);
  }

  Future<String> create(String businessId, Appointment appt) async {
    final doc = await _col(businessId).add({
      ...appt.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(String businessId, Appointment appt) async {
    await _col(businessId).doc(appt.id).update({
      ...appt.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(
    String businessId,
    String appointmentId,
    String status, {
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (notes != null) data['statusNote'] = notes;
    await _col(businessId).doc(appointmentId).update(data);
  }
}
