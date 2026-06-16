import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthResponse? get user => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;

  bool isLoading = false;
  String? errorMessage;

  Future<void> init() async {
    await _authService.loadFromStorage();
    notifyListeners();
  }
  Future<void> reloadUser() async {
    await _authService.reloadPremiumStatus();
    notifyListeners();
  }
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Invalid email or password.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String dateOfBirth,
    required int countryId,
    required int cityId,
    String? phone,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
        countryId: countryId,
        cityId: cityId,
        phone: phone,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  Future<String?> getToken() => _authService.getToken();
}