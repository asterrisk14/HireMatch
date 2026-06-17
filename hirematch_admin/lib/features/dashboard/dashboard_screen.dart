import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/theme/app_colors.dart';
import 'dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats> _future;

  @override
  void initState() {
    super.initState();
    _future = DashboardService.load();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = DashboardService.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<DashboardStats>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load data from the server.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final stats = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.work_outline,
                        label: 'Open jobs',
                        value: stats.openJobs.toString(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.people_outline,
                        label: 'Total candidates',
                        value: stats.totalCandidates.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Jobs expiring soon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: stats.expiringJobs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No jobs expiring soon',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              AppColors.bgPage,
                            ),
                            headingTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                            columns: const [
                              DataColumn(label: Text('JOB TITLE')),
                              DataColumn(label: Text('APPLICATION DEADLINE')),
                              DataColumn(label: Text('TIME REMAINING')),
                              DataColumn(label: Text('APPLICATIONS')),
                            ],
                            rows: stats.expiringJobs
                                .map(
                                  (job) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          job.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          DateFormat(
                                            'dd.MM.yyyy',
                                          ).format(job.expiryDate),
                                        ),
                                      ),
                                      DataCell(Text(job.timeRemaining)),
                                      DataCell(
                                        Text(job.applications.toString()),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
