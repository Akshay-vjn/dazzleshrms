class AttendanceQrRequest {
  final String method;
  final LocationData location;

  AttendanceQrRequest({
    required this.method,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'location': location.toJson(),
    };
  }
}

class LocationData {
  final double lat;
  final double lng;
  final double accuracy;

  LocationData({
    required this.lat,
    required this.lng,
    required this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
    };
  }
}