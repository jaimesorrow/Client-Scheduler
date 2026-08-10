import 'package:cloud_firestore/cloud_firestore.dart';

class TimeoffBlock {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;

  const TimeoffBlock({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  factory TimeoffBlock.fromMap(String id, Map<String, dynamic> data) {
    return TimeoffBlock(
      id: id,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      reason: data['reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'reason': reason,
      };
}
