import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.keyToken);
    return _token;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Future<Map<String, String>> getHeaders({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type':  'application/json',
      'Accept':        'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final headers  = await getHeaders(auth: auth);
      final response = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: ApiConstants.receiveTimeout));
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final uri      = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers  = await getHeaders(auth: auth);
      final response = await http.post(
        uri,
        headers: headers,
        body:    jsonEncode(body),
      ).timeout(const Duration(seconds: ApiConstants.receiveTimeout));
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final uri      = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers  = await getHeaders(auth: auth);
      final response = await http.put(
        uri,
        headers: headers,
        body:    jsonEncode(body),
      ).timeout(const Duration(seconds: ApiConstants.receiveTimeout));
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool auth = true,
  }) async {
    try {
      final uri      = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers  = await getHeaders(auth: auth);
      final response = await http.delete(uri, headers: headers)
          .timeout(const Duration(seconds: ApiConstants.receiveTimeout));
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success':    false,
        'message':    'Invalid response from server',
        'statusCode': response.statusCode,
      };
    }
  }
}
