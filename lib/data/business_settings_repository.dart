import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_settings.dart';

class BusinessSettingsRepository {
  final FirebaseFirestore _firestore;

  BusinessSettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String businessId) =>
      _firestore.collection('businessSettings').doc(businessId);

  Future<BusinessSettings?> getSettings(String businessId) async {
    final doc = await _doc(businessId).get();
    if (!doc.exists) return null;
    return BusinessSettings.fromMap(doc.id, doc.data()!);
  }

  Future<void> create(
    String businessId, {
    String? businessName,
    String timezone = 'America/New_York',
  }) async {
    await _doc(businessId).set({
      'businessId': businessId,
      'onboardingComplete': false,
      'businessName': businessName,
      'timezone': timezone,
      'workingDays': {
        'Mon': true,
        'Tue': true,
        'Wed': true,
        'Thu': true,
        'Fri': true,
        'Sat': false,
        'Sun': false,
      },
      'workingHours': {
        'Mon': {'open': '09:00', 'close': '17:00'},
        'Tue': {'open': '09:00', 'close': '17:00'},
        'Wed': {'open': '09:00', 'close': '17:00'},
        'Thu': {'open': '09:00', 'close': '17:00'},
        'Fri': {'open': '09:00', 'close': '17:00'},
        'Sat': {'open': '09:00', 'close': '17:00'},
        'Sun': {'open': '09:00', 'close': '17:00'},
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(
    String businessId,
    Map<String, dynamic> fields,
  ) async {
    await _doc(businessId).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setOnboardingComplete(String businessId) async {
    await _doc(businessId).update({
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
