import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../application_statuses/application_statuses_service.dart';
import '../job_posts/job_posts_service.dart';
import 'application_status_dialog.dart';
import 'applications_report_pdf.dart';
import 'applications_service.dart';
import 'dart:typed_data';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  static const _pageSize = 10;

  List<Application> _items = [];
  List<JobPost> _jobPosts = [];
  List<ApplicationStatus> _statuses = [];
  int _page = 1;
  int _totalCount = 0;
  int? _jobPostFilter;
  int? _statusFilter;
  bool _loading = true;
  bool _filtersLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _load();
  }

  Future<void> _loadFilters() async {
    setState(() => _filtersLoading = true);
    try {
      final results = await Future.wait([
        JobPostsService.listAll(),
        ApplicationStatusesService.listAll(),
      ]);
      setState(() {
        _jobPosts = results[0] as List<JobPost>;
        _statuses = results[1] as List<ApplicationStatus>;
        _filtersLoading = false;
      });
    } catch (_) {
      setState(() => _filtersLoading = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApplicationsService.list(
        jobPostId: _jobPostFilter,
        applicationStatusId: _statusFilter,
        page: _page,
        pageSize: _pageSize,
      );
      setState(() {
        _items = result.result;
        _totalCount = result.totalCount;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load applications from the server.';
        _loading = false;
      });
    }
  }

  void _onJobPostFilterChanged(int? value) {
    _jobPostFilter = value;
    _page = 1;
    _load();
  }

  void _onStatusFilterChanged(int? value) {
    _statusFilter = value;
    _page = 1;
    _load();
  }

  void _onPageChanged(int page) {
    _page = page;
    _load();
  }

  Future<void> _changeStatus(Application application) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ApplicationStatusDialog(
        application: application,
        statuses: _statuses,
      ),
    );
    if (saved == true) {
      await _load();
      if (mounted)
        showAppSnackBar(context, 'Application status updated successfully.');
    }
  }

  Future<void> _openCv(Application application) async {
    if (application.cvUrl.isEmpty) return;
    final ok = await launchUrl(
      Uri.parse('${ApiConfig.baseUrl}${application.cvUrl}'),
    );
    if (!ok && mounted) {
      showAppSnackBar(context, 'Unable to open this CV file.', isError: true);
    }
  }

  Future<void> _delete(Application application) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Application',
      message:
          'Are you sure you want to delete the application from '
          '"${application.candidateFullName}"? This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await ApplicationsService.delete(application.id);
      await _load();
      if (mounted)
        showAppSnackBar(context, 'Application deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _downloadReport() async {
    final applications = await ApplicationsService.listAllForReport(
      jobPostId: _jobPostFilter,
      applicationStatusId: _statusFilter,
    );
    final bytes = await buildApplicationsReportPdf(applications);

    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(bytes),
      name: 'hirematch-applications-report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _downloadReport,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Download Report'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _jobPostFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter by job post',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All job posts'),
                      ),
                      ..._jobPosts.map(
                        (j) =>
                            DropdownMenuItem(value: j.id, child: Text(j.title)),
                      ),
                    ],
                    onChanged: _filtersLoading ? null : _onJobPostFilterChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _statusFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter by status',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All statuses'),
                      ),
                      ..._statuses.map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      ),
                    ],
                    onChanged: _filtersLoading ? null : _onStatusFilterChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
            const SizedBox(height: 12),
            PaginationBar(
              page: _page,
              pageSize: _pageSize,
              totalCount: _totalCount,
              onPageChanged: _onPageChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No applications found.'));
    }
    return Card(
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: item.companyLogoUrl.isNotEmpty
                  ? NetworkImage('${ApiConfig.baseUrl}${item.companyLogoUrl}')
                  : null,
              child: item.companyLogoUrl.isEmpty
                  ? const Icon(Icons.business_outlined)
                  : null,
            ),
            title: Text('${item.candidateFullName} → ${item.jobPostTitle}'),
            subtitle: Text(
              '${item.companyName} · Applied ${DateFormat('dd.MM.yyyy').format(item.appliedAt)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.applicationStatusName,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.description_outlined),
                  tooltip: item.cvUrl.isEmpty ? 'No CV uploaded' : 'View CV',
                  onPressed: item.cvUrl.isEmpty ? null : () => _openCv(item),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Change Status',
                  onPressed: _filtersLoading ? null : () => _changeStatus(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _delete(item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
