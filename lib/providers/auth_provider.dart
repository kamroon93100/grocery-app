import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool    get isLoading  => _isLoading;
  bool    get isLoggedIn => _currentUser != null;
  bool    get isAdmin    => _currentUser?['isAdmin']  ?? false;
  bool    get isDelivery => _currentUser?['role']     == 'delivery';
  String  get userId     => _currentUser?['id']       ?? '';
  String  get userName   => _currentUser?['name']     ?? '';
  String  get userEmail  => _currentUser?['email']    ?? '';
  String  get userPhone  => _currentUser?['phone']    ?? '';
  String  get userRole   => _currentUser?['role']     ?? 'customer';
  double  get wallet     => (_currentUser?['wallet']  ?? 0.0).toDouble();
  String? get error      => _error;

  Future<void> checkAuth() async {
    _currentUser = await _auth.getCurrentUser();
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    final result = await _auth.login(email, password);
    if (result['success'] == true) {
      _currentUser = await _auth.getCurrentUser();
    } else {
      _error = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    final result = await _auth.register(
      name:     name,
      email:    email,
      phone:    phone,
      password: password,
    );
    if (result['success'] == true) {
      _currentUser = await _auth.getCurrentUser();
    } else {
      _error = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> sendOTP(String phone) async {
    _isLoading = true; notifyListeners();
    final result = await _auth.sendOTP(phone);
    _isLoading = false; notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String otp,
    String? name,
    String? email,
  }) async {
    _isLoading = true; notifyListeners();
    final result = await _auth.verifyOTP(
      phone: phone, otp: otp, name: name, email: email,
    );
    if (result['success'] == true) {
      _currentUser = await _auth.getCurrentUser();
    } else {
      _error = result['message'];
    }
    _isLoading = false; notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> resendOTP(String phone) async {
    return await _auth.resendOTP(phone);
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _auth.logout();
    _currentUser = null;
    _isLoading   = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPass, String newPass) async {
    return await _auth.changePassword(oldPass, newPass);
  }

  void updateWallet(double amount) {
    if (_currentUser != null) {
      _currentUser!['wallet'] = amount;
      notifyListeners();
    }
  }
}

