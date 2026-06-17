import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/job_post.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final JobService _jobService = JobService();
  JobPost? _job;
  bool _loadingJob = true;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    final jobPostId = widget.application['jobPostId'];
    if (jobPostId == null) {
      setState(() => _loadingJob = false);
      return;
    }
    try {
      final job = await _jobService.getJobById(jobPostId);
      setState(() {
        _job = job;
        _loadingJob = false;
      });
    } catch (_) {
      setState(() => _loadingJob = false);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return '—';
    }
  }

  Future<void> _openCv(String cvUrl) async {
    final fullUrl = '${ApiConfig.baseUrl}$cvUrl';
    await launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final title = app['jobPostTitle'] ?? '';
    final company = app['companyName'] ?? '';
    final status = app['applicationStatusName'] ?? '';
    final logoUrl = (app['companyLogoUrl'] ?? '').toString();
    final cvUrl = (app['cvUrl'] ?? '').toString();
    final date = _formatDate(app['appliedAt']?.toString());

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Application details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _logoFallback(title),
                          ),
                        )
                      : _logoFallback(title),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealDark,
                        ),
                      ),
                      if (company.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            company,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    color: AppColors.tealDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: const TextStyle(color: AppColors.tealDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.calendar_today_outlined, 'Applied on', date),
            const Divider(height: 28),
            if (cvUrl.isNotEmpty) ...[
              const Text(
                'Submitted CV',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _openCv(cvUrl),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Open CV'),
              ),
              const Divider(height: 28),
            ],
            const Text(
              'Job description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_loadingJob)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_job != null) ...[
              Text(
                _job!.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              if (_job!.location.isNotEmpty)
                _detailRow(
                  Icons.location_on_outlined,
                  'Location',
                  _job!.location,
                ),
              if (_job!.employmentTypeName.isNotEmpty)
                _detailRow(
                  Icons.work_outline,
                  'Employment type',
                  _job!.employmentTypeName,
                ),
              if (_job!.compensation.isNotEmpty)
                _detailRow(
                  Icons.payments_outlined,
                  'Compensation',
                  _job!.compensation,
                ),
            ] else
              const Text(
                'Job details unavailable.',
                style: TextStyle(color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoFallback(String title) {
    return Center(
      child: Text(
        title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.tealDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
