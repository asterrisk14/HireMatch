import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:5086';
    if (Platform.isAndroid) return 'http://10.0.2.2:5086';
    return 'http://localhost:5086';
  }
}

class AuthService {
  static const _tokenKey = 'hirematch_token';
  static const _userKey = 'hirematch_user';
  static const Duration _timeoutDuration = Duration(seconds: 15);

  AuthResponse? _currentUser;
  AuthResponse? get currentUser => _currentUser;

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = AuthResponse.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      await logout();
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/Account/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(
          _timeoutDuration,
          onTimeout: () => throw Exception(
            'Connection timed out. Check that the backend is running and reachable.',
          ),
        );

    if (response.statusCode == 200) {
      final data = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveUser(data);
      return data;
    } else {
      throw Exception(
        _extractErrorMessage(
          response.body,
          fallback: 'Invalid email or password.',
        ),
      );
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String dateOfBirth,
    required int countryId,
    required int cityId,
    String? phone,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/Account/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'password': password,
            'dateOfBirth': dateOfBirth,
            'countryId': countryId,
            'cityId': cityId,
            'phone': phone ?? '',
          }),
        )
        .timeout(
          _timeoutDuration,
          onTimeout: () => throw Exception(
            'Connection timed out. Check that the backend is running and reachable.',
          ),
        );

    if (response.statusCode == 200) {
      final data = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveUser(data);
      return data;
    } else {
      throw Exception(
        _extractErrorMessage(response.body, fallback: 'Registration failed.'),
      );
    }
  }

  Future<void> _saveUser(AuthResponse user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await getToken();
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/Account/change-password'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        )
        .timeout(
          _timeoutDuration,
          onTimeout: () => throw Exception('Connection timed out.'),
        );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response.body,
          fallback: 'Failed to change password.',
        ),
      );
    }
  }

  Future<void> reloadPremiumStatus() async {
    final user = _currentUser;
    if (user == null) return;
    final token = await getToken();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/Candidates/${user.id}'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final isPremium = data['isPremium'] ?? false;
      final updated = AuthResponse(
        id: user.id,
        email: user.email,
        token: user.token,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        phone: user.phone,
        isPremium: isPremium,
      );
      await _saveUser(updated);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  bool get isLoggedIn => _currentUser != null;

  String _extractErrorMessage(String responseBody, {required String fallback}) {
    try {
      final body = jsonDecode(responseBody);
      if (body is Map && body['message'] != null)
        return body['message'].toString();
      if (body is String && body.isNotEmpty) return body;
    } catch (_) {}
    return fallback;
  }
}
