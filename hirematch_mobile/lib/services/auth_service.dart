import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class ApiConfig {
  /// API adresa se čita iz --dart-define=API_BASE_URL=... pri pokretanju.
  /// Ako nije proslijeđena, koristi se default vrijednost ispod.
  ///
  /// Primjer pokretanja za fizički telefon:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.0.3:5086
  ///
  /// Za emulator: --dart-define=API_BASE_URL=http://10.0.2.2:5086
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.3:5086',
  );
}

class AuthService {
  static const _tokenKey = 'hirematch_token';
  static const _userKey = 'hirematch_user';

  AuthResponse? _currentUser;
  AuthResponse? get currentUser => _currentUser;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = AuthResponse.fromJson(jsonDecode(userJson));
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Account/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveUser(data);
      return data;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String dateOfBirth, // format: yyyy-MM-dd
    required int countryId,
    required int cityId,
    String? phone,
  }) async {
    final response = await http.post(
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
    ).timeout(const Duration(seconds: 15), onTimeout: () {
      throw Exception('Connection timed out. Check that the backend is running and reachable.');
    });

    if (response.statusCode == 200) {
      final data = AuthResponse.fromJson(jsonDecode(response.body));
      await _saveUser(data);
      return data;
    } else {
      // ignore: avoid_print
      print('Register failed: ${response.statusCode} - ${response.body}');
      throw Exception('Registration failed: ${response.body}');
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

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Account/change-password'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'Failed to change password.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) message = body['message'];
      } catch (_) {}
      throw Exception(message);
    }
  }

  /// Osvježava isPremium status korisnika sa backenda (poslije plaćanja/refunda).
  Future<void> reloadPremiumStatus() async {
    final user = _currentUser;
    if (user == null) return;
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Candidates/${user.id}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
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
}