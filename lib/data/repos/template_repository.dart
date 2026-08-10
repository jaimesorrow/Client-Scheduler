import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/template.dart';

class TemplateRepository {
  final FirebaseFirestore _firestore;

  TemplateRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String businessId) =>
      _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('templates');

  Future<List<Template>> list(String businessId) async {
    final snap = await _col(businessId).orderBy('name').get();
    return snap.docs.map((d) => Template.fromMap(d.id, d.data())).toList();
  }

  Future<Template?> get(String businessId, String templateId) async {
    final doc = await _col(businessId).doc(templateId).get();
    if (!doc.exists) return null;
    return Template.fromMap(doc.id, doc.data()!);
  }

  Future<String> create(String businessId, Template template) async {
    final doc = await _col(businessId).add({
      ...template.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> update(String businessId, Template template) async {
    await _col(businessId).doc(template.id).update({
      ...template.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String businessId, String templateId) async {
    await _col(businessId).doc(templateId).delete();
  }
}
