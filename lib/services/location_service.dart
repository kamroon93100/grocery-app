import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit:       const Duration(seconds: 15),
      );

      // Use free reverse geocoding API
      String address = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      String city = '';

      try {
        final response = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1'),
          headers: {'User-Agent': 'GroceryApp/1.0'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          address = data['display_name'] ?? address;
          city = data['address']?['city'] ??
                 data['address']?['town'] ??
                 data['address']?['village'] ?? '';
        }
      } catch (_) {}

      return {
        'latitude':      position.latitude,
        'longitude':     position.longitude,
        'fullAddress':   address,
        'line1':         address.split(',').take(2).join(',').trim(),
        'line2':         '',
        'city':          city,
        'state':         '',
        'pincode':       '',
        'country':       'India',
        'googleMapsUrl': 'https://www.google.com/maps?q=${position.latitude},${position.longitude}',
      };
    } catch (e) {
      return null;
    }
  }
}
