import 'api_service.dart';
import '../constants/api_constants.dart';

class GoogleMapsService {
  static final GoogleMapsService _instance = GoogleMapsService._internal();
  factory GoogleMapsService() => _instance;
  GoogleMapsService._internal();

  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> geocode(String address) async {
    final result = await _api.get('/maps/geocode', queryParams: {
      'address': address,
    }, auth: false);
    if (result['success'] == true) return result['data'];
    return null;
  }

  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lng) async {
    final result = await _api.get('/maps/reverse-geocode', queryParams: {
      'lat': lat.toString(),
      'lng': lng.toString(),
    }, auth: false);
    if (result['success'] == true) return result['data'];
    return null;
  }

  Future<List<Map<String, dynamic>>?> distanceMatrix({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final result = await _api.get('/maps/distance-matrix', queryParams: {
      'originLat': originLat.toString(),
      'originLng': originLng.toString(),
      'destLat': destLat.toString(),
      'destLng': destLng.toString(),
    }, auth: false);
    if (result['success'] == true && result['data'] != null) {
      return List<Map<String, dynamic>>.from(result['data']['rows'] ?? []);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> placeAutocomplete(String input) async {
    final result = await _api.get('/maps/places/autocomplete', queryParams: {
      'input': input,
    }, auth: false);
    if (result['success'] == true) {
      return List<Map<String, dynamic>>.from(
        result['data']['predictions'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>?> placeDetails(String placeId, {double? lat, double? lon}) async {
    final params = <String, String>{};
    if (placeId.isNotEmpty) params['placeId'] = placeId;
    if (lat != null) params['lat'] = lat.toString();
    if (lon != null) params['lon'] = lon.toString();
    final result = await _api.get('/maps/places/details',
      queryParams: params, auth: false);
    if (result['success'] == true) return result['data'] as Map<String, dynamic>?;
    return null;
  }
}
