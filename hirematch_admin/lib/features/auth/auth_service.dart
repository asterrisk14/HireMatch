import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthUser {
  final int? userId;
  final String email;
  final String? fullName;
  final String role;

  AuthUser({
    required this.userId,
    required this.email,
    this.fullName,
    required this.role,
  });

  factory AuthUser.fromLoginResponse(Map<String, dynamic> json) {
    final first = json['firstName']?.toString() ?? '';
    final last = json['lastName']?.toString() ?? '';
    final fullName = [first, last].where((s) => s.isNotEmpty).join(' ');
    return AuthUser(
      userId: int.tryParse(json['id']?.toString() ?? ''),
      email: json['email']?.toString() ?? '',
      fullName: fullName.isEmpty ? null : fullName,
      role: json['role']?.toString() ?? AppRoles.admin,
    );
  }

  factory AuthUser.fromStorageJson(Map<String, dynamic> json) => AuthUser(
        userId: json['userId'] is int ? json['userId'] as int : null,
        email: json['email']?.toString() ?? '',
        fullName: json['fullName']?.toString(),
        role: json['role']?.toString() ?? AppRoles.admin,
      );

  Map<String, dynamic> toStorageJson() => {
        'userId': userId,
        'email': email,
        'fullName': fullName,
        'role': role,
      };
}

class AuthService {
  static Future<AuthUser> login(String email, String password) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      withAuth: false,
    ) as Map<String, dynamic>;

    final token = response['token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException(500, 'The server did not return a valid token.');
    }

    final user = AuthUser.fromLoginResponse(response);
    await TokenStorage.saveSession(token, jsonEncode(user.toStorageJson()));
    return user;
  }

  static Future<AuthUser?> restoreSession() async {
    final token = await TokenStorage.getToken();
    final userJson = await TokenStorage.getUserJson();
    if (token == null || userJson == null) return null;
    if (_isExpired(token)) {
      await TokenStorage.clear();
      return null;
    }
    return AuthUser.fromStorageJson(
      jsonDecode(userJson) as Map<String, dynamic>,
    );
  }

  static Future<void> logout() => TokenStorage.clear();

  static Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  static bool _isExpired(String token) {
    final payload = _decodePayload(token);
    final exp = payload['exp'];
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiry);
  }
}
