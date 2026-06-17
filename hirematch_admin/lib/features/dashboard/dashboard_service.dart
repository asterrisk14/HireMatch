import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

class DashboardStats {
  final int openJobs;
  final int totalCandidates;
  final List<ExpiringJob> expiringJobs;

  DashboardStats({
    required this.openJobs,
    required this.totalCandidates,
    required this.expiringJobs,
  });
}

class ExpiringJob {
  final String title;
  final DateTime expiryDate;
  final int applications;

  ExpiringJob({
    required this.title,
    required this.expiryDate,
    required this.applications,
  });

  String get timeRemaining {
    final diff = expiryDate.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    if (days > 0) return '${days}d ${hours}h';
    return '${diff.inHours}h';
  }
}

class DashboardService {
  static Future<DashboardStats> load() async {
    final jobsJson =
        await ApiClient.instance.get(
              ApiEndpoints.jobPosts,
              query: {
                'isActive': true,
                'retrieveTotalCount': true,
                'pageSize': 100,
                'page': 1,
              },
            )
            as Map<String, dynamic>;

    final jobList = (jobsJson['result'] as List?) ?? const [];
    final totalJobs = jobsJson['totalCount'] ?? jobList.length;

    final now = DateTime.now();
    final in5Days = now.add(const Duration(days: 5));

    final expiring =
        jobList
            .map((j) => j as Map<String, dynamic>)
            .where((j) => j['expiryDate'] != null)
            .map(
              (j) => ExpiringJob(
                title: j['title']?.toString() ?? '',
                expiryDate: DateTime.parse(j['expiryDate'].toString()),
                applications: j['applicationCount'] ?? 0,
              ),
            )
            .where(
              (j) =>
                  j.expiryDate.isAfter(now) && j.expiryDate.isBefore(in5Days),
            )
            .toList()
          ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    int totalCandidates = 0;
    try {
      final candidatesJson =
          await ApiClient.instance.get(
                ApiEndpoints.candidates,
                query: {'retrieveTotalCount': true, 'pageSize': 1, 'page': 1},
              )
              as Map<String, dynamic>;
      totalCandidates = candidatesJson['totalCount'] ?? 0;
    } catch (_) {}

    return DashboardStats(
      openJobs: totalJobs,
      totalCandidates: totalCandidates,
      expiringJobs: expiring.take(10).toList(),
    );
  }
}
