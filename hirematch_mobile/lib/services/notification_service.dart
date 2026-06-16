import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_notification.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class NotificationService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> getNotifications() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Notifications')
        .replace(queryParameters: {'Page': '1', 'PageSize': '50', 'RetrieveTotalCount': 'true'});
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<int> getUnreadCount() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Notifications/unread-count'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  Future<void> markAsRead(int id) async {
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Notifications/$id/read'),
      headers: await _headers(),
    );
  }

  Future<void> markAllAsRead() async {
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Notifications/read-all'),
      headers: await _headers(),
    );
  }
}