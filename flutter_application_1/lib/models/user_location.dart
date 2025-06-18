import 'dart:math';

class UserLocation {
  final String uid;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;

  UserLocation({
    required this.uid,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory UserLocation.fromMap(Map<String, dynamic> map, String uid, double currentLat, double currentLng) {
    final name = map['name']?.toString() ?? 'Utilizador';
    final address = map['address']?.toString() ?? 'Endereço não disponível';
    final latitude = map['latitude']?.toDouble() ?? 0.0;
    final longitude = map['longitude']?.toDouble() ?? 0.0;
    
    // Calculate distance using Haversine formula
    final distance = _calculateDistance(currentLat, currentLng, latitude, longitude);
    
    return UserLocation(
      uid: uid,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distance: distance,
    );
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(_degreesToRadians(lat1)) * sin(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
    };
  }
} 