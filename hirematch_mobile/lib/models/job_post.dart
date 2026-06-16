class JobPost {
  final int id;
  final int companyId;
  final String companyName;
  final String companyLogoUrl;
  final int recruiterId;
  final String title;
  final String description;
  final String compensation;
  final int employmentTypeId;
  final String employmentTypeName;
  final int? industryId;
  final String industryName;
  final bool isPaid;
  final String location;
  final DateTime expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationCount;

  JobPost({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.companyLogoUrl,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.compensation,
    required this.employmentTypeId,
    required this.employmentTypeName,
    this.industryId,
    required this.industryName,
    required this.isPaid,
    required this.location,
    required this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.applicationCount,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'] ?? 0,
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      companyLogoUrl: json['companyLogoUrl'] ?? '',
      recruiterId: json['recruiterId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      compensation: json['compensation'] ?? '',
      employmentTypeId: json['employmentTypeId'] ?? 0,
      employmentTypeName: json['employmentTypeName'] ?? '',
      industryId: json['industryId'],
      industryName: json['industryName'] ?? '',
      isPaid: json['isPaid'] ?? false,
      location: json['location'] ?? '',
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      applicationCount: json['applicationCount'] ?? 0,
    );
  }

  bool get isActive => expiryDate.isAfter(DateTime.now());
}

class PagedResult<T> {
  final List<T> result;
  final int totalCount;

  PagedResult({required this.result, required this.totalCount});

  factory PagedResult.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PagedResult(
      result: (json['result'] as List<dynamic>? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class Industry {
  final int id;
  final String name;
  Industry({required this.id, required this.name});
  factory Industry.fromJson(Map<String, dynamic> json) =>
      Industry(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class EmploymentType {
  final int id;
  final String name;
  EmploymentType({required this.id, required this.name});
  factory EmploymentType.fromJson(Map<String, dynamic> json) =>
      EmploymentType(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class Skill {
  final int id;
  final String name;
  Skill({required this.id, required this.name});
  factory Skill.fromJson(Map<String, dynamic> json) =>
      Skill(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class RecommendedJob {
  final int id;
  final String title;
  final String companyName;
  final String companyLogoUrl;
  final String location;
  final String employmentTypeName;
  final int score;
  final String explanation;

  RecommendedJob({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyLogoUrl,
    required this.location,
    required this.employmentTypeName,
    required this.score,
    required this.explanation,
  });

  factory RecommendedJob.fromJson(Map<String, dynamic> json) => RecommendedJob(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    companyName: json['companyName'] ?? '',
    companyLogoUrl: json['companyLogoUrl'] ?? '',
    location: json['location'] ?? '',
    employmentTypeName: json['employmentTypeName'] ?? '',
    score: json['score'] ?? 0,
    explanation: json['explanation'] ?? '',
  );
}