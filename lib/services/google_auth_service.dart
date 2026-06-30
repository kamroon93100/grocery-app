import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../constants/api_constants.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return {'success': false, 'message': 'Sign in cancelled'};
      }

      final authData = await account.authentication;
      final idToken = authData.idToken;
      if (idToken == null) {
        return {'success': false, 'message': 'Failed to get ID token'};
      }

      // Send token to our backend
      final result = await _api.post(
        ApiConstants.googleLogin,
        {'idToken': idToken},
        auth: false,
      );

      if (result['success'] == true) {
        final user = result['data']['user'];
        final token = result['data']['accessToken'];
        final refreshToken = result['data']['refreshToken'];
        await _auth.saveSessionFromMap(user, token, refreshToken);
        _api.setToken(token);
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}


