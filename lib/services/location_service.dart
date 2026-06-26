import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // Check if location service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit:       const Duration(seconds: 15),
      );

      // Convert to address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;
      final place = placemarks.first;

      final addressParts = <String>[];
      if (place.name?.isNotEmpty == true && place.name != place.street)
        addressParts.add(place.name!);
      if (place.street?.isNotEmpty == true) addressParts.add(place.street!);
      if (place.subLocality?.isNotEmpty == true) addressParts.add(place.subLocality!);

      return {
        'latitude':    position.latitude,
        'longitude':   position.longitude,
        'fullAddress': addressParts.join(', '),
        'line1':       addressParts.take(2).join(', '),
        'line2':       place.subLocality ?? '',
        'city':        place.locality ?? '',
        'state':       place.administrativeArea ?? '',
        'pincode':     place.postalCode ?? '',
        'country':     place.country ?? 'India',
        'googleMapsUrl': 'https://www.google.com/maps?q=${position.latitude},${position.longitude}',
      };
    } catch (e) {
      return null;
    }
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
