import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Industry-grade location fetch (like Zomato/Swiggy)
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Step 1: Check if location service is enabled (GPS ON)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          errorType: LocationErrorType.serviceDisabled,
          message: 'GPS is OFF. Please enable Location services in Settings.',
          actionLabel: 'Enable GPS',
        );
      }

      // Step 2: Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            errorType: LocationErrorType.permissionDenied,
            message: 'Location permission denied. Please allow location access.',
            actionLabel: 'Grant Permission',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          errorType: LocationErrorType.permissionDeniedForever,
          message: 'Location permission permanently denied. Enable in app settings.',
          actionLabel: 'Open Settings',
        );
      }

      // Step 3: Try to get LAST KNOWN position first (FAST - 0 sec)
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      // Step 4: Get CURRENT position with HIGH accuracy
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } catch (timeoutError) {
        // Fallback to last known if timeout
        if (lastKnown != null) {
          position = lastKnown;
        } else {
          // Try with lower accuracy as final fallback
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 10),
              ),
            );
          } catch (_) {
            return LocationResult(
              success: false,
              errorType: LocationErrorType.timeout,
              message: 'Location timeout. Make sure you have GPS signal (try going outside).',
              actionLabel: 'Try Again',
            );
          }
        }
      }

      // Step 5: Reverse geocode (get address from lat/lng)
      final addressData = await _reverseGeocode(
        position.latitude, position.longitude);

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        fullAddress: addressData['fullAddress'] ?? '',
        line1: addressData['line1'] ?? '',
        city: addressData['city'] ?? '',
        state: addressData['state'] ?? '',
        pincode: addressData['pincode'] ?? '',
        country: addressData['country'] ?? 'India',
        googleMapsUrl: 'https://www.google.com/maps?q=${position.latitude},${position.longitude}',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        errorType: LocationErrorType.unknown,
        message: 'Could not get location: ${e.toString()}',
        actionLabel: 'Try Again',
      );
    }
  }

  /// Free reverse geocoding using OpenStreetMap
  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      // Try multiple geocoding services for reliability
      final result = await _tryNominatim(lat, lng);
      if (result != null) return result;

      final result2 = await _tryBigDataCloud(lat, lng);
      if (result2 != null) return result2;
    } catch (_) {}

    // Final fallback - just lat/lng
    return {
      'fullAddress': '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
      'line1':       '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
      'city':        '',
      'state':       '',
      'pincode':     '',
      'country':     'India',
    };
  }

  /// Try Nominatim (OpenStreetMap) - Free, no API key
  Future<Map<String, String>?> _tryNominatim(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?'
            'format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {
          'User-Agent': 'KohliStore/2.0 (kohli.store@grocery.com)',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final parts = <String>[];
        if (address['house_number'] != null) parts.add(address['house_number']);
        if (address['road']         != null) parts.add(address['road']);
        if (address['neighbourhood']!= null) parts.add(address['neighbourhood']);
        if (address['suburb']       != null) parts.add(address['suburb']);

        final line1 = parts.isEmpty
            ? (address['display_name'] ?? '').toString().split(',').take(2).join(',').trim()
            : parts.join(', ');

        return {
          'fullAddress': data['display_name'] ?? '',
          'line1':       line1,
          'city':        address['city'] ??
                         address['town'] ??
                         address['village'] ??
                         address['suburb'] ?? '',
          'state':       address['state'] ?? '',
          'pincode':     address['postcode'] ?? '',
          'country':     address['country'] ?? 'India',
        };
      }
    } catch (_) {}
    return null;
  }

  /// Backup - BigDataCloud (Free, no API key)
  Future<Map<String, String>?> _tryBigDataCloud(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?'
            'latitude=$lat&longitude=$lng&localityLanguage=en'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'fullAddress': '${data['locality'] ?? ''}, ${data['city'] ?? ''}, ${data['principalSubdivision'] ?? ''}',
          'line1':       '${data['locality'] ?? ''}, ${data['city'] ?? ''}',
          'city':        data['city'] ?? data['locality'] ?? '',
          'state':       data['principalSubdivision'] ?? '',
          'pincode':     data['postcode'] ?? '',
          'country':     data['countryName'] ?? 'India',
        };
      }
    } catch (_) {}
    return null;
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings to grant permission
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}

/// Result class for clean error handling
class LocationResult {
  final bool                success;
  final double?             latitude;
  final double?             longitude;
  final double?             accuracy;
  final String              fullAddress;
  final String              line1;
  final String              city;
  final String              state;
  final String              pincode;
  final String              country;
  final String              googleMapsUrl;
  final LocationErrorType?  errorType;
  final String              message;
  final String              actionLabel;

  LocationResult({
    this.success = false,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.fullAddress  = '',
    this.line1        = '',
    this.city         = '',
    this.state        = '',
    this.pincode      = '',
    this.country      = 'India',
    this.googleMapsUrl= '',
    this.errorType,
    this.message      = '',
    this.actionLabel  = '',
  });
}

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}
