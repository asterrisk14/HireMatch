import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class JobPost {
  final int id;
  final int companyId;
  final String companyName;
  final String companyLogoUrl;
  final String title;
  final String description;
  final String compensation;
  final int employmentTypeId;
  final String employmentTypeName;
  final bool isPaid;
  final int? cityId;
  final String cityName;
  final int? workModeId;
  final String workModeName;
  final DateTime expiryDate;
  final DateTime createdAt;
  final int? industryId;
  final String industryName;
  final int applicationCount;

  JobPost({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.companyLogoUrl,
    required this.title,
    required this.description,
    required this.compensation,
    required this.employmentTypeId,
    required this.employmentTypeName,
    required this.isPaid,
    required this.cityId,
    required this.cityName,
    required this.workModeId,
    required this.workModeName,
    required this.expiryDate,
    required this.createdAt,
    required this.industryId,
    required this.industryName,
    required this.applicationCount,
  });

  bool get isActive => expiryDate.isAfter(DateTime.now());

  factory JobPost.fromJson(Map<String, dynamic> json) => JobPost(
        id: json['id'],
        companyId: json['companyId'] ?? 0,
        companyName: json['companyName'] ?? '',
        companyLogoUrl: json['companyLogoUrl'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        compensation: json['compensation'] ?? '',
        employmentTypeId: json['employmentTypeId'] ?? 0,
        employmentTypeName: json['employmentTypeName'] ?? '',
        isPaid: json['isPaid'] ?? false,
        cityId: json['cityId'],
        cityName: json['cityName'] ?? '',
        workModeId: json['workModeId'],
        workModeName: json['workModeName'] ?? '',
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'].toString())
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        industryId: json['industryId'],
        industryName: json['industryName'] ?? '',
        applicationCount: json['applicationCount'] ?? 0,
      );
}

class JobPostsService {
  static Future<List<JobPost>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<PagedResult<JobPost>> list({
    String? title,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.jobPosts,
              query: {
                if (title != null && title.isNotEmpty) 'Title': title,
                if (isActive != null) 'IsActive': isActive,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => JobPost.fromJson(e));
  }

  static Future<JobPost> create({
    required String title,
    required String description,
    required int companyId,
    required int recruiterId,
    required int employmentTypeId,
    required int industryId,
    int? cityId,
    int? workModeId,
    required String compensation,
    required DateTime expiryDate,
    required List<int> skillIds,
  }) async {
    final json =
        await ApiClient.instance.post(
              ApiEndpoints.jobPosts,
              body: {
                'companyId': companyId,
                'recruiterId': recruiterId,
                'title': title,
                'description': description,
                'cityId': cityId,
                'workModeId': workModeId,
                'compensation': compensation,
                'employmentTypeId': employmentTypeId,
                'industryId': industryId,
                'expiryDate': expiryDate.toIso8601String(),
                'skillIds': skillIds,
              },
            )
            as Map<String, dynamic>;
    return JobPost.fromJson(json);
  }

  static Future<JobPost> update({
    required int id,
    required String title,
    required String description,
    required int companyId,
    required int recruiterId,
    required int employmentTypeId,
    int? cityId,
    int? workModeId,
    required String compensation,
    required DateTime expiryDate,
    required List<int> skillIds,
  }) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.jobPosts}/$id',
              body: {
                'companyId': companyId,
                'recruiterId': recruiterId,
                'title': title,
                'description': description,
                'cityId': cityId,
                'workModeId': workModeId,
                'compensation': compensation,
                'employmentTypeId': employmentTypeId,
                'expiryDate': expiryDate.toIso8601String(),
                'skillIds': skillIds,
              },
            )
            as Map<String, dynamic>;
    return JobPost.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.jobPosts}/$id');
  }
}
