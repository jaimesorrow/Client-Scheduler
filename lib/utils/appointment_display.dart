String summarizeServices(List<String> serviceNames) {
  if (serviceNames.isEmpty) return 'No services';
  if (serviceNames.length == 1) return serviceNames.first;
  if (serviceNames.length == 2)
    return '${serviceNames[0]} + ${serviceNames[1]}';
  return '${serviceNames[0]} + ${serviceNames.length - 1} more';
}

String formatDuration(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

String formatPrice(int? cents) {
  if (cents == null) return '—';
  final dollars = cents / 100.0;
  return '\$${dollars.toStringAsFixed(2)}';
}
