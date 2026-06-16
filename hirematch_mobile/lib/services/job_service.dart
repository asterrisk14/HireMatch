import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_post.dart';
import '../models/candidate.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

class JobService {
  final AuthService _authService = AuthService();

  Future<List<RecommendedJob>> getRecommended() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/JobPosts/recommended'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => RecommendedJob.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> updatePreferences({
    required int candidateId,
    int? preferredIndustryId,
    int? preferredEmploymentTypeId,
  }) async {
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Candidates/$candidateId/preferences'),
      headers: await _headers(),
      body: jsonEncode({
        'preferredIndustryId': preferredIndustryId,
        'preferredEmploymentTypeId': preferredEmploymentTypeId,
      }),
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<PagedResult<JobPost>> getJobPosts({
    String? keyword,
    String? location,
    int? industryId,
    int? employmentTypeId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      'RetrieveTotalCount': 'true',
    };
    if (keyword != null && keyword.isNotEmpty) params['Keyword'] = keyword;
    if (location != null && location.isNotEmpty) params['Location'] = location;
    if (industryId != null) params['IndustryId'] = industryId.toString();
    if (employmentTypeId != null) params['EmploymentTypeId'] = employmentTypeId.toString();

    final uri = Uri.parse('${ApiConfig.baseUrl}/JobPosts').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      return PagedResult.fromJson(jsonDecode(response.body), JobPost.fromJson);
    }
    throw Exception('Failed to load job posts (${response.statusCode})');
  }

  /// Vraća unique gradove iz kompanija u bazi - za dropdown lokacija
  Future<List<String>> getCities() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Companies?PageSize=200'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cities = (data['result'] as List<dynamic>)
          .map((c) => (c['city'] ?? '').toString())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      cities.sort();
      return cities;
    }
    return [];
  }

  Future<JobPost> getJobById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/JobPosts/$id'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return JobPost.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load job');
  }

  Future<List<Industry>> getIndustries() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Industries?PageSize=100'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>)
          .map((e) => Industry.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load industries');
  }

  Future<List<EmploymentType>> getEmploymentTypes() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/EmploymentTypes?PageSize=100'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>)
          .map((e) => EmploymentType.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load employment types');
  }

  Future<List<Skill>> getSkills() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Skills?PageSize=100'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>)
          .map((e) => Skill.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load skills');
  }

  Future<void> addUserSkill(int userId, String skillName) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/UserSkills'),
      headers: await _headers(),
      body: jsonEncode({'userId': userId, 'skillName': skillName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add skill');
    }
  }

  Future<bool> hasApplied(int candidateId, int jobPostId) async {
    final params = {
      'CandidateId': candidateId.toString(),
      'JobPostId': jobPostId.toString(),
      'RetrieveTotalCount': 'true',
      'PageSize': '1',
      'Page': '1',
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/Applications').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['totalCount'] ?? 0) > 0;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getMyApplications(int candidateId) async {
    final params = {
      'CandidateId': candidateId.toString(),
      'RetrieveTotalCount': 'true',
      'PageSize': '50',
      'Page': '1',
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/Applications').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Candidate> getCandidateById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Candidates/$id'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return Candidate.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load candidate');
  }

  Future<Candidate> updateCandidate({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required int? countryId,
    required int? cityId,
    required String currentTitle,
    required int yearsOfExperience,
    required String summary,
    required List<String> skills,
    required String linkedInUrl,
    required String portfolioUrl,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Candidates/$id'),
      headers: await _headers(),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'countryId': countryId,
        'cityId': cityId,
        'currentTitle': currentTitle,
        'yearsOfExperience': yearsOfExperience,
        'summary': summary,
        'skills': skills,
        'linkedInUrl': linkedInUrl,
        'portfolioUrl': portfolioUrl,
      }),
    );
    if (response.statusCode == 200) {
      return Candidate.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update profile (${response.statusCode}): ${response.body}');
  }

  Future<Candidate> uploadCv(int id, String filePath) async {
    final token = await _authService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/Candidates/$id/cv');
    final request = http.MultipartRequest('PUT', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('cvFile', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Candidate.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to upload CV (${response.statusCode})');
  }

  Future<Candidate> uploadProfilePicture(int id, String filePath) async {
    final token = await _authService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/Candidates/$id/picture');
    final request = http.MultipartRequest('PUT', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('pictureFile', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Candidate.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to upload picture (${response.statusCode})');
  }

  /// Apliciranje na poziciju + upload CV-a.
  /// candidateId se NE šalje - backend ga uzima iz JWT tokena.
  Future<void> applyToJob({
    required int jobPostId,
    String? cvFilePath,
  }) async {
    final token = await _authService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/Applications');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['jobPostId'] = jobPostId.toString();
    request.fields['applicationStatusId'] = ApplicationStatusIds.newApplication.toString();

    if (cvFilePath != null) {
      request.files.add(await http.MultipartFile.fromPath('cvFile', cvFilePath));
    }

    final streamedResponse = await request.send();
    if (streamedResponse.statusCode != 200 && streamedResponse.statusCode != 201) {
      throw Exception('Failed to apply');
    }
  }
}