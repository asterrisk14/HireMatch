import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String> createPaymentIntent() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Payment/create-intent'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['clientSecret'] as String;
    }
    throw Exception('Failed to create payment: ${response.body}');
  }

  Future<void> refundPremium() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Payment/refund'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      String message = 'Refund failed.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) message = body['message'];
      } catch (_) {}
      throw Exception(message);
    }
  }
}
