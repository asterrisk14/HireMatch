import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ApiException(this.statusCode, this.message, {this.fieldErrors});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isConflict => statusCode == 409;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleanQuery[key] = value.toString();
      }
    });
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: cleanQuery.isEmpty ? null : cleanQuery,
    );
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: await _headers());
    return _handle(res);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool withAuth = true,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(withAuth: withAuth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http.put(
      _uri(path),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: await _headers());
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final status = res.statusCode;
    if (status >= 200 && status < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    String message = 'Something went wrong. Please try again.';
    Map<String, List<String>>? fieldErrors;

    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['errors'] is Map) {
            fieldErrors = (decoded['errors'] as Map).map(
              (k, v) => MapEntry(
                k.toString(),
                (v is List ? v : [v]).map((e) => e.toString()).toList(),
              ),
            );
            message = fieldErrors.values.expand((e) => e).join('\n');
          } else if (decoded['message'] != null) {
            message = decoded['message'].toString();
          } else if (decoded['title'] != null) {
            message = decoded['title'].toString();
          }
        }
      } catch (_) {}
    }

    if (message == 'Something went wrong. Please try again.') {
      switch (status) {
        case 401:
          message = 'Your session has expired. Please sign in again.';
          break;
        case 403:
          message = "You don't have permission to perform this action.";
          break;
        case 404:
          message = 'The requested record was not found.';
          break;
        case 409:
          message = 'This record cannot be saved or deleted because it is in use.';
          break;
      }
    }

    throw ApiException(status, message, fieldErrors: fieldErrors);
  }
}
