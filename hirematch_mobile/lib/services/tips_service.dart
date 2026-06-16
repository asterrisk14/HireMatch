import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CareerTip {
  final int id;
  final String title;
  final String content;
  final String icon;

  CareerTip({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
  });

  factory CareerTip.fromJson(Map<String, dynamic> json) => CareerTip(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    icon: json['icon'] ?? '💡',
  );
}

class TipsService {
  final AuthService _authService = AuthService();

  Future<List<CareerTip>> getTips() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/CareerTips?PageSize=20&RetrieveTotalCount=true'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>).map((e) => CareerTip.fromJson(e)).toList();
    }
    return [];
  }
}