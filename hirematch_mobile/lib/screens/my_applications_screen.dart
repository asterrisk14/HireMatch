import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/job_service.dart';
import '../providers/auth_provider.dart';
import 'application_detail_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final JobService _jobService = JobService();
  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final candidateId = context.read<AuthProvider>().user?.id;
    if (candidateId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final apps = await _jobService.getMyApplications(candidateId);
      setState(() {
        _applications = apps;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My applications'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _applications.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'You haven\'t applied to any jobs yet.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final app = _applications[index];
              final title = app['jobPostTitle'] ?? '';
              final company = app['companyName'] ?? '';
              final status = app['applicationStatusName'] ?? '';
              final logoUrl = (app['companyLogoUrl'] ?? '').toString();
              final date = _formatDate(app['appliedAt']?.toString());

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: logoUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _logoFallback(title),
                      ),
                    )
                        : _logoFallback(title),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (company.toString().isNotEmpty) Text(company),
                      if (date.isNotEmpty)
                        Text('Applied: $date',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tealDark,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ApplicationDetailScreen(application: app),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _logoFallback(String title) {
    return Center(
      child: Text(
        title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(color: AppColors.tealDark, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}