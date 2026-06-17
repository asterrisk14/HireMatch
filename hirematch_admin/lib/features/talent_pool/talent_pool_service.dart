import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class Candidate {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int? countryId;
  final String countryName;
  final int? cityId;
  final String cityName;
  final String currentTitle;
  final int yearsOfExperience;
  final String summary;
  final List<String> skills;
  final String linkedInUrl;
  final String portfolioUrl;
  final String cvUrl;
  final String profilePictureUrl;
  final bool isPremium;
  final String preferredIndustryName;
  final String preferredEmploymentTypeName;

  Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.countryId,
    required this.countryName,
    required this.cityId,
    required this.cityName,
    required this.currentTitle,
    required this.yearsOfExperience,
    required this.summary,
    required this.skills,
    required this.linkedInUrl,
    required this.portfolioUrl,
    required this.cvUrl,
    required this.profilePictureUrl,
    required this.isPremium,
    required this.preferredIndustryName,
    required this.preferredEmploymentTypeName,
  });

  String get fullName => '$firstName $lastName';

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
        id: json['id'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        countryId: json['countryId'],
        countryName: json['countryName'] ?? '',
        cityId: json['cityId'],
        cityName: json['cityName'] ?? '',
        currentTitle: json['currentTitle'] ?? '',
        yearsOfExperience: json['yearsOfExperience'] ?? 0,
        summary: json['summary'] ?? '',
        skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        linkedInUrl: json['linkedInUrl'] ?? '',
        portfolioUrl: json['portfolioUrl'] ?? '',
        cvUrl: json['cvUrl'] ?? '',
        profilePictureUrl: json['profilePictureUrl'] ?? '',
        isPremium: json['isPremium'] ?? false,
        preferredIndustryName: json['preferredIndustryName'] ?? '',
        preferredEmploymentTypeName: json['preferredEmploymentTypeName'] ?? '',
      );
}

class CandidatesService {
  static Future<PagedResult<Candidate>> list({
    String? search,
    bool? isPremium,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.candidates,
              query: {
                if (search != null && search.isNotEmpty) 'Keyword': search,
                if (isPremium != null) 'IsPremium': isPremium,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => Candidate.fromJson(e));
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.candidates}/$id');
  }
}
