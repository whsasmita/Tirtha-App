import 'package:flutter/material.dart';
import 'package:tirtha_app/core/services/app_client.dart';
import 'package:tirtha_app/data/models/user_model.dart';
import 'package:tirtha_app/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get role => _user?.role;

  Future<void> login(String email, String password, String? fcmToken, String timezone) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.login(email, password, fcmToken, timezone);
      
      // setelah login sukses → ambil profil
      final userProfile = await _authService.getUserProfile();
      _user = userProfile;
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await ApiClient.getToken();
    if (token != null) {
      try {
        _user = await _authService.getUserProfile();
        _isAuthenticated = true;
      } catch (_) {
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}