import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's location and update it in the database
  static Future<bool> updateCurrentUserLocation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Endereço não disponível';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.postalCode,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      // Update user data in Firebase
      await _database.ref('userdata/${user.uid}').update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'lastLocationUpdate': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  /// Get user's current location from database
  static Future<Map<String, dynamic>?> getCurrentUserLocation() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _database.ref('userdata/${user.uid}').get();
      if (!snapshot.exists) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;
      return {
        'latitude': data['latitude']?.toDouble(),
        'longitude': data['longitude']?.toDouble(),
        'address': data['address']?.toString(),
      };
    } catch (e) {
      print('Error getting user location: $e');
      return null;
    }
  }

  /// Update user's address manually
  static Future<bool> updateUserAddress(String address) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Try to geocode the address
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        await _database.ref('userdata/${user.uid}').update({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': address,
          'lastLocationUpdate': DateTime.now().toIso8601String(),
        });
        return true;
      } else {
        // If geocoding fails, just save the address
        await _database.ref('userdata/${user.uid}').update({
          'address': address,
          'lastLocationUpdate': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }
} 