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
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static Future<AnalyticsStats> load() async {
    final results = await Future.wait([
      ApiClient.instance.get(
        ApiEndpoints.jobPosts,
        query: {'RetrieveTotalCount': true, 'Page': 1, 'PageSize': 1},
      ),
      ApiClient.instance.get(
        ApiEndpoints.candidates,
        query: {'RetrieveTotalCount': true, 'Page': 1, 'PageSize': 1},
      ),
      ApiClient.instance.get(
        ApiEndpoints.applications,
        query: {'RetrieveTotalCount': true, 'Page': 1, 'PageSize': 100},
      ),
    ]);

    final jobsJson = results[0] as Map<String, dynamic>;
    final candidatesJson = results[1] as Map<String, dynamic>;
    final applicationsJson = results[2] as Map<String, dynamic>;

    final jobsPosted = jobsJson['totalCount'] ?? 0;
    final candidatesCount = candidatesJson['totalCount'] ?? 0;
    final applicationsCount = applicationsJson['totalCount'] ?? 0;
    final applicationsList = (applicationsJson['result'] as List?) ?? const [];

    final counts = <String, int>{};
    for (final raw in applicationsList) {
      final app = raw as Map<String, dynamic>;
      final appliedAtRaw = app['appliedAt'];
      if (appliedAtRaw == null) continue;
      final date = DateTime.parse(appliedAtRaw.toString());
      final key = _monthNames[date.month - 1];
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final now = DateTime.now();
    final labels = <String>[];
    final data = <int>[];
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final label = _monthNames[d.month - 1];
      labels.add(label);
      data.add(counts[label] ?? 0);
    }

    return AnalyticsStats(
      jobsPosted: jobsPosted,
      candidates: candidatesCount,
      applications: applicationsCount,
      totalUsers: candidatesCount,
      monthLabels: labels,
      monthlyApplications: data,
    );
  }
}
