import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final _secure = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _api.post(
        ApiConstants.login,
        {'email': email, 'password': password},
        auth: false,
      );

      final data = result['data'] ?? result;

      if (result['success'] == true || data['accessToken'] != null) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
        final token = (data['accessToken'] ?? data['token']).toString();
        final refreshToken = (data['refreshToken'] ?? '').toString();

        await _saveSession(user, token, refreshToken);
        _api.setToken(token);

        return {
          'success': true,
          'data': data,
          'message': 'Login successful',
        };
      }

      return {
        'success': false,
        'message': result['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final result = await _api.post(
      ApiConstants.register,
      {'name': name, 'email': email, 'phone': phone, 'password': password},
      auth: false,
    );
    if (result['success'] == true) {
      final user  = UserModel.fromJson(result['data']['user']);
      final token = (result['data']['accessToken'] ?? result['data']['token']).toString();
      final refreshToken = (result['data']['refreshToken'] ?? '').toString();
      await _saveSession(user, token, refreshToken);
      _api.setToken(token);
    }
    return result;
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout, {}).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Server logout is best-effort; local tokens are cleared regardless
    }
    _api.clearToken();
    await _secure.delete(key: AppConstants.keyToken);
    await _secure.delete(key: AppConstants.keyRefreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserPhone);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyIsLogged);
    await prefs.remove(AppConstants.keyWallet);
  }

  Future<void> _saveSession(UserModel user, String token, String refreshToken) async {
    await _secure.write(key: AppConstants.keyToken, value: token);
    await _secure.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId,       user.id);
    await prefs.setString(AppConstants.keyUserName,     user.name);
    await prefs.setString(AppConstants.keyUserEmail,    user.email);
    await prefs.setString(AppConstants.keyUserPhone,    user.phone);
    await prefs.setString(AppConstants.keyUserRole,     user.role);
    await prefs.setBool(AppConstants.keyIsLogged,       true);
    await prefs.setDouble(AppConstants.keyWallet,       user.walletBalance);
  }

  Future<void> saveSessionFromMap(Map<String, dynamic> user, String token, String refreshToken) async {
    await _secure.write(key: AppConstants.keyToken, value: token);
    await _secure.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId,       user['id'] ?? '');
    await prefs.setString(AppConstants.keyUserName,     user['name'] ?? '');
    await prefs.setString(AppConstants.keyUserEmail,    user['email'] ?? '');
    await prefs.setString(AppConstants.keyUserPhone,    user['phone'] ?? '');
    await prefs.setString(AppConstants.keyUserRole,     user['role'] ?? 'customer');
    await prefs.setBool(AppConstants.keyIsLogged,       true);
    await prefs.setDouble(AppConstants.keyWallet,       (user['walletBalance'] ?? 0.0).toDouble());
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLogged) ?? false;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(AppConstants.keyIsLogged) ?? false)) return null;
    return {
      'id':      prefs.getString(AppConstants.keyUserId),
      'name':    prefs.getString(AppConstants.keyUserName),
      'email':   prefs.getString(AppConstants.keyUserEmail),
      'phone':   prefs.getString(AppConstants.keyUserPhone),
      'role':    prefs.getString(AppConstants.keyUserRole),
      'wallet':  prefs.getDouble(AppConstants.keyWallet) ?? 0.0,
      'isAdmin': prefs.getString(AppConstants.keyUserRole) == 'admin',
      'token':   await _secure.read(key: AppConstants.keyToken),
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get(ApiConstants.me);
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword, String newPassword) async {
    return await _api.put(ApiConstants.changePassword, {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> sendOTP(String phone) async {
    return await _api.post(
      ApiConstants.sendOTP,
      {'phone': phone},
      auth: false,
    );
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String otp,
    String? name,
    String? email,
  }) async {
    final body = <String, dynamic>{'phone': phone, 'otp': otp};
    if (name  != null) body['name']  = name;
    if (email != null) body['email'] = email;

    final result = await _api.post(ApiConstants.verifyOTP, body, auth: false);
    if (result['success'] == true) {
      final user  = UserModel.fromJson(result['data']['user']);
      final token = (result['data']['accessToken'] ?? result['data']['token']).toString();
      final refreshToken = (result['data']['refreshToken'] ?? '').toString();
      await _saveSession(user, token, refreshToken);
      _api.setToken(token);
    }
    return result;
  }

  Future<Map<String, dynamic>> resendOTP(String phone) async {
    return await _api.post(
      ApiConstants.resendOTP,
      {'phone': phone},
      auth: false,
    );
  }

  Future<Map<String, dynamic>> updateProfile(
    String name, String phone) async {
    return await _api.put(ApiConstants.updateProfile, {
      'name':  name,
      'phone': phone,
    });
  }
}





