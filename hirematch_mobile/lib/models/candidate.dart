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
  final int? preferredIndustryId;
  final String preferredIndustryName;
  final int? preferredEmploymentTypeId;
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
    this.preferredIndustryId,
    this.preferredIndustryName = '',
    this.preferredEmploymentTypeId,
    this.preferredEmploymentTypeName = '',
  });

  // Spojeni prikaz lokacije, npr. "Sarajevo, Bosna i Hercegovina"
  String get locationDisplay {
    final parts = [cityName, countryName].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? 0,
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
      skills: (json['skills'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      linkedInUrl: json['linkedInUrl'] ?? '',
      portfolioUrl: json['portfolioUrl'] ?? '',
      cvUrl: json['cvUrl'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      preferredIndustryId: json['preferredIndustryId'],
      preferredIndustryName: json['preferredIndustryName'] ?? '',
      preferredEmploymentTypeId: json['preferredEmploymentTypeId'],
      preferredEmploymentTypeName: json['preferredEmploymentTypeName'] ?? '',
    );
  }
}