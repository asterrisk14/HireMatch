import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../../shared/widgets/common_widgets.dart';
import 'analytics_report_pdf.dart';
import 'analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<AnalyticsStats> _future;

  @override
  void initState() {
    super.initState();
    _future = AnalyticsService.load();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = AnalyticsService.load();
    });
  }

  Future<void> _downloadReport(AnalyticsStats stats) async {
    final bytes = await buildAnalyticsReportPdf(stats);

    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(bytes),
      name: 'hirematch-analytics-report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<AnalyticsStats>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load analytics data from the server.'),
            );
          }
          final stats = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    StatCard(
                      icon: Icons.work_outline,
                      label: 'Jobs posted',
                      value: stats.jobsPosted.toString(),
                    ),
                    StatCard(
                      icon: Icons.people_outline,
                      label: 'Candidates',
                      value: stats.candidates.toString(),
                    ),
                    StatCard(
                      icon: Icons.assignment_outlined,
                      label: 'Applications',
                      value: stats.applications.toString(),
                    ),
                    StatCard(
                      icon: Icons.group_outlined,
                      label: 'Total users',
                      value: stats.totalUsers.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _downloadReport(stats),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Download Report'),
                ),
                const SizedBox(height: 28),
                Text(
                  'Applications trend (last 6 months)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _MonthlyBarChart(
                      labels: stats.monthLabels,
                      values: stats.monthlyApplications,
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

class _MonthlyBarChart extends StatelessWidget {
  final List<String> labels;
  final List<int> values;

  const _MonthlyBarChart({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(labels.length, (i) {
          final heightFactor = values[i] / safeMax;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    values[i].toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 140 * heightFactor.clamp(0.02, 1.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5BFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
