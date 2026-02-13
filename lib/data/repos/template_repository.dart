import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/template.dart';

class TemplateRepository {
  final FirebaseFirestore _firestore;

  TemplateRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String businessId) =>
      _firestore.collection('businesses').doc(businessId).collection('templates');

  Future<List<Template>> list(String businessId) async {
    final snap = await _col(businessId).orderBy('name').get();
    return snap.docs.map((d) => Template.fromMap(d.id, d.data())).toList();
  }

  Future<void> create(String businessId, Template template) async {
    await _col(businessId).add(template.toMap());
  }

  Future<void> update(String businessId, Template template) async {
    await _col(businessId).doc(template.id).update(template.toMap());
  }
}
