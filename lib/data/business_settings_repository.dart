import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_settings.dart';

class BusinessSettingsRepository {
  final FirebaseFirestore _firestore;

  BusinessSettingsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<BusinessSettings?> getSettings(String businessId) async {
    final doc = await _firestore
        .collection('businessSettings')
        .doc(businessId)
        .get();
    if (!doc.exists) return null;
    return BusinessSettings.fromMap(doc.id, doc.data()!);
  }
}
