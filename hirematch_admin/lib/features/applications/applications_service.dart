import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class Application {
  final int id;
  final int candidateId;
  final String candidateFirstName;
  final String candidateLastName;
  final String candidateEmail;
  final int jobPostId;
  final String jobPostTitle;
  final int applicationStatusId;
  final String applicationStatusName;
  final DateTime appliedAt;
  final String companyName;
  final String companyLogoUrl;
  final String cvUrl;

  Application({
    required this.id,
    required this.candidateId,
    required this.candidateFirstName,
    required this.candidateLastName,
    required this.candidateEmail,
    required this.jobPostId,
    required this.jobPostTitle,
    required this.applicationStatusId,
    required this.applicationStatusName,
    required this.appliedAt,
    required this.companyName,
    required this.companyLogoUrl,
    required this.cvUrl,
  });

  String get candidateFullName => '$candidateFirstName $candidateLastName';

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        id: json['id'],
        candidateId: json['candidateId'] ?? 0,
        candidateFirstName: json['candidateFirstName'] ?? '',
        candidateLastName: json['candidateLastName'] ?? '',
        candidateEmail: json['candidateEmail'] ?? '',
        jobPostId: json['jobPostId'] ?? 0,
        jobPostTitle: json['jobPostTitle'] ?? '',
        applicationStatusId: json['applicationStatusId'] ?? 0,
        applicationStatusName: json['applicationStatusName'] ?? '',
        appliedAt: json['appliedAt'] != null
            ? DateTime.parse(json['appliedAt'].toString())
            : DateTime.now(),
        companyName: json['companyName'] ?? '',
        companyLogoUrl: json['companyLogoUrl'] ?? '',
        cvUrl: json['cvUrl'] ?? '',
      );
}

class ApplicationsService {
  static Future<PagedResult<Application>> list({
    int? jobPostId,
    int? applicationStatusId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.applications,
              query: {
                if (jobPostId != null) 'JobPostId': jobPostId,
                if (applicationStatusId != null)
                  'ApplicationStatusId': applicationStatusId,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => Application.fromJson(e));
  }

  static Future<List<Application>> listAllForReport({
    int? jobPostId,
    int? applicationStatusId,
  }) async {
    final result = await list(
      jobPostId: jobPostId,
      applicationStatusId: applicationStatusId,
      page: 1,
      pageSize: 1000,
    );
    return result.result;
  }

  static Future<Application> updateStatus(
    int id,
    int applicationStatusId,
  ) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.applications}/$id',
              body: {'applicationStatusId': applicationStatusId},
            )
            as Map<String, dynamic>;
    return Application.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.applications}/$id');
  }
}
