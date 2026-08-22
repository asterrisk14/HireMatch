import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

class AnalyticsStats {
  final int jobsPosted;
  final int candidates;
  final int applications;
  final int totalUsers;
  final List<String> monthLabels;
  final List<int> monthlyApplications;

  AnalyticsStats({
    required this.jobsPosted,
    required this.candidates,
    required this.applications,
    required this.totalUsers,
    required this.monthLabels,
    required this.monthlyApplications,
  });
}

class AnalyticsService {
  static Future<AnalyticsStats> load() async {
    final json =
        await ApiClient.instance.get(ApiEndpoints.analytics)
            as Map<String, dynamic>;

    return AnalyticsStats(
      jobsPosted: json['jobsPosted'] ?? 0,
      candidates: json['candidates'] ?? 0,
      applications: json['applications'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      monthLabels:
          (json['monthLabels'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      monthlyApplications:
          (json['monthlyApplications'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}
