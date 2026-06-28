import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _secure = const FlutterSecureStorage();

  String? _token;
  String? _refreshToken;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await _secure.read(key: AppConstants.keyToken);
    _refreshToken = await _secure.read(key: AppConstants.keyRefreshToken);
    return _token;
  }

  void setToken(String token) {
    _token = token;
  }

  Future<void> setRefreshToken(String token) async {
    _refreshToken = token;
    await _secure.write(key: AppConstants.keyRefreshToken, value: token);
  }

  void clearToken() {
    _token = null;
    _refreshToken = null;
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return _token != null;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(const Duration(seconds: ApiConstants.receiveTimeout));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final newToken = body['data']['accessToken'];
          final newRefresh = body['data']['refreshToken'];
          _token = newToken;
          _refreshToken = newRefresh;
          await _secure.write(key: AppConstants.keyToken, value: newToken);
          await _secure.write(key: AppConstants.keyRefreshToken, value: newRefresh);
          _isRefreshing = false;
          _refreshCompleter!.complete(true);
          return true;
        }
      }
    } catch (_) {}
    _isRefreshing = false;
    _refreshCompleter!.complete(false);
    return false;
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

  Future<http.Response> _executeRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    if (method == 'GET') {
      return await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: ApiConstants.receiveTimeout));
    } else if (method == 'POST') {
      return await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: ApiConstants.receiveTimeout));
    } else if (method == 'PUT') {
      return await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: ApiConstants.receiveTimeout));
    } else {
      return await http.delete(uri, headers: headers)
          .timeout(const Duration(seconds: ApiConstants.receiveTimeout));
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    const maxRetries = 2;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
        if (queryParams != null && queryParams.isNotEmpty) {
          uri = uri.replace(queryParameters: queryParams);
        }
        final headers = await getHeaders(auth: auth);

        var response = await _executeRequest(method, uri, headers: headers, body: body);

        var result = _handleResponse(response);
        if (result['statusCode'] == 401 && await _tryRefreshToken()) {
          final newHeaders = await getHeaders(auth: auth);
          response = await _executeRequest(method, uri, headers: newHeaders, body: body);
          result = _handleResponse(response);
        }

        final statusCode = response.statusCode;
        if (statusCode >= 500 && statusCode < 600 && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 1 << attempt));
          continue;
        }

        return result;
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 1 << attempt));
          continue;
        }
        return {'success': false, 'message': e.toString()};
      }
    }
    return {'success': false, 'message': 'Request failed after retries'};
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) => _request('GET', endpoint, queryParams: queryParams, auth: auth);

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _request('POST', endpoint, body: body, auth: auth);

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = true,
  }) => _request('PUT', endpoint, body: body, auth: auth);

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool auth = true,
  }) => _request('DELETE', endpoint, auth: auth);

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
