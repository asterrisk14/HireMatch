import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FavouriteItem {
  final int favouriteId;
  final int jobPostId;
  final String jobPostTitle;
  final String companyName;
  final String companyLogoUrl;
  final String location;
  final String employmentTypeName;
  final String expiryDate;

  FavouriteItem({
    required this.favouriteId,
    required this.jobPostId,
    required this.jobPostTitle,
    required this.companyName,
    required this.companyLogoUrl,
    required this.location,
    required this.employmentTypeName,
    required this.expiryDate,
  });

  factory FavouriteItem.fromJson(Map<String, dynamic> json) => FavouriteItem(
    favouriteId: json['id'] ?? 0,
    jobPostId: json['jobPostId'] ?? 0,
    jobPostTitle: json['jobPostTitle'] ?? '',
    companyName: json['companyName'] ?? '',
    companyLogoUrl: json['companyLogoUrl'] ?? '',
    location: json['location'] ?? '',
    employmentTypeName: json['employmentTypeName'] ?? '',
    expiryDate: json['expiryDate'] ?? '',
  );
}

class SavedJobsService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<FavouriteItem>> getFavourites(int candidateId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/Favourites').replace(queryParameters: {
      'CandidateId': candidateId.toString(),
      'PageSize': '50',
      'Page': '1',
      'RetrieveTotalCount': 'true',
    });
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>).map((e) => FavouriteItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> addFavourite(int candidateId, int jobPostId) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Favourites'),
      headers: await _headers(),
      body: jsonEncode({'candidateId': candidateId, 'jobPostId': jobPostId}),
    );
  }

  Future<void> removeFavourite(int favouriteId) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/Favourites/$favouriteId'),
      headers: await _headers(),
    );
  }
}