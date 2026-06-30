import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<LocationResult> getCurrentLocation() async {
    try {
      // Step 1: Check GPS enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          errorType: LocationErrorType.serviceDisabled,
          message: 'GPS is OFF. Please enable Location services.',
          actionLabel: 'Enable GPS',
        );
      }

      // Step 2: Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            errorType: LocationErrorType.permissionDenied,
            message: 'Location permission denied.',
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

      // Step 3: Try last known position first
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      // Step 4: Get current position with HIGH accuracy
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (timeoutError) {
        if (lastKnown != null) {
          position = lastKnown;
        } else {
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 10),
            );
          } catch (_) {
            return LocationResult(
              success: false,
              errorType: LocationErrorType.timeout,
              message: 'Location timeout. Try going outside for better GPS signal.',
              actionLabel: 'Try Again',
            );
          }
        }
      }

      // Step 5: Reverse geocode
      final addressData = await _reverseGeocode(position.latitude, position.longitude);

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
        message: 'Error: ${e.toString()}',
        actionLabel: 'Try Again',
      );
    }
  }

  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      final result = await _tryNominatim(lat, lng);
      if (result != null) return result;

      final result2 = await _tryBigDataCloud(lat, lng);
      if (result2 != null) return result2;
    } catch (_) {}

    return {
      'fullAddress': '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
      'line1':       '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
      'city':        '',
      'state':       '',
      'pincode':     '',
      'country':     'India',
    };
  }

  Future<Map<String, String>?> _tryNominatim(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?'
            'format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'KohliStore/2.0'},
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
            ? (data['display_name'] ?? '').toString().split(',').take(2).join(',').trim()
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

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}

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

