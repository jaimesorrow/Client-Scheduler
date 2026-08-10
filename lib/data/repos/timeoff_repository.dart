import 'package:cloud_firestore/cloud_firestore.dart';
import '../timeoff_block.dart';

class TimeoffRepository {
  final FirebaseFirestore _firestore;

  TimeoffRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String businessId) =>
      _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('timeoff');

  Future<List<TimeoffBlock>> list(String businessId) async {
    final snap =
        await _col(businessId).orderBy('startDate', descending: false).get();
    return snap.docs
        .map((d) => TimeoffBlock.fromMap(d.id, d.data()))
        .toList();
  }

  Future<String> create(String businessId, TimeoffBlock block) async {
    final doc = await _col(businessId).add({
      ...block.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> delete(String businessId, String blockId) async {
    await _col(businessId).doc(blockId).delete();
  }
}
