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

  Future<void> create(String businessId, Appointment appt) async {
    await _col(businessId).add(appt.toMap());
  }

  Future<void> update(String businessId, Appointment appt) async {
    await _col(businessId).doc(appt.id).update(appt.toMap());
  }
}
