import 'package:flutter/material.dart';
import 'models/service.dart';

class AppointmentDraftProvider extends ChangeNotifier {
  String? clientId;
  String? clientName;
  List<String> serviceIds = [];
  List<String> serviceNames = [];
  int totalDurationMin = 0;
  int totalPriceCents = 0;
  DateTime? date;
  TimeOfDay? time;
  String notes = '';

  bool get isReadyToBook =>
      clientId != null && serviceIds.isNotEmpty && date != null && time != null;

  DateTime? get startAt {
    if (date == null || time == null) return null;
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }

  DateTime? get endAt {
    final s = startAt;
    if (s == null) return null;
    return s.add(Duration(minutes: totalDurationMin));
  }

  void setClient(String id, String name) {
    clientId = id;
    clientName = name;
    notifyListeners();
  }

  void setServices(List<Service> services) {
    serviceIds = services.map((s) => s.id).toList();
    serviceNames = services.map((s) => s.name).toList();
    totalDurationMin =
        services.fold(0, (sum, s) => sum + s.durationMinutes);
    totalPriceCents =
        services.fold(0, (sum, s) => sum + (s.priceCents ?? 0));
    notifyListeners();
  }

  void setDateTime(DateTime d, TimeOfDay t) {
    date = d;
    time = t;
    notifyListeners();
  }

  void setNotes(String n) {
    notes = n;
    notifyListeners();
  }

  void clear() {
    clientId = null;
    clientName = null;
    serviceIds = [];
    serviceNames = [];
    totalDurationMin = 0;
    totalPriceCents = 0;
    date = null;
    time = null;
    notes = '';
    notifyListeners();
  }
}
