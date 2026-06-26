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

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _api.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
    if (result['success'] == true) {
      final user  = UserModel.fromJson(result['data']['user']);
      final token = result['data']['accessToken'];
      final refreshToken = result['data']['refreshToken'];
      await _saveSession(user, token, refreshToken);
      _api.setToken(token);
    }
    return result;
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
      final token = result['data']['accessToken'];
      final refreshToken = result['data']['refreshToken'];
      await _saveSession(user, token, refreshToken);
      _api.setToken(token);
    }
    return result;
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout, {});
    } catch (_) {}
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveSession(UserModel user, String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyToken,        token);
    await prefs.setString(AppConstants.keyRefreshToken, refreshToken);
    await prefs.setString(AppConstants.keyUserId,       user.id);
    await prefs.setString(AppConstants.keyUserName,     user.name);
    await prefs.setString(AppConstants.keyUserEmail,    user.email);
    await prefs.setString(AppConstants.keyUserPhone,    user.phone);
    await prefs.setString(AppConstants.keyUserRole,     user.role);
    await prefs.setBool(AppConstants.keyIsLogged,       true);
    await prefs.setDouble(AppConstants.keyWallet,       user.walletBalance);
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
      'token':   prefs.getString(AppConstants.keyToken),
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

  Future<Map<String, dynamic>> updateProfile(
    String name, String phone) async {
    return await _api.put(ApiConstants.updateProfile, {
      'name':  name,
      'phone': phone,
    });
  }
}
