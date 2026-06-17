import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../auth/auth_provider.dart';
import 'job_post_form_dialog.dart';
import 'job_posts_service.dart';

class JobPostsScreen extends StatefulWidget {
  const JobPostsScreen({super.key});

  @override
  State<JobPostsScreen> createState() => _JobPostsScreenState();
}

class _JobPostsScreenState extends State<JobPostsScreen> {
  static const _pageSize = 10;

  List<JobPost> _items = [];
  int _page = 1;
  int _totalCount = 0;
  String _search = '';
  bool? _isActiveFilter;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await JobPostsService.list(
        title: _search,
        isActive: _isActiveFilter,
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
        _error = 'Unable to load job posts from the server.';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _search = value;
    _page = 1;
    _load();
  }

  void _onStatusFilterChanged(bool? value) {
    _isActiveFilter = value;
    _page = 1;
    _load();
  }

  void _onPageChanged(int page) {
    _page = page;
    _load();
  }

  Future<void> _openForm({JobPost? jobPost}) async {
    final currentUserId = context.read<AuthProvider>().currentUser?.userId;
    if (currentUserId == null) {
      showAppSnackBar(
        context,
        'Unable to determine the current user. Please sign in again.',
        isError: true,
      );
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => JobPostFormDialog(
        jobPost: jobPost,
        currentUserId: currentUserId,
      ),
    );
    if (saved == true) {
      _page = 1;
      await _load();
      if (mounted) {
        showAppSnackBar(
          context,
          jobPost == null
              ? 'Job post added successfully.'
              : 'Job post updated successfully.',
        );
      }
    }
  }

  Future<void> _delete(JobPost jobPost) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Job Post',
      message:
          'Are you sure you want to delete "${jobPost.title}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await JobPostsService.delete(jobPost.id);
      await _load();
      if (mounted) showAppSnackBar(context, 'Job post deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This job post cannot be deleted because it has existing applications.'
              : e.message,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Posts'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Job Post'),
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
                SearchField(
                  hintText: 'Search by job title...',
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<bool?>(
                    initialValue: _isActiveFilter,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: true, child: Text('Active')),
                      DropdownMenuItem(value: false, child: Text('Expired')),
                    ],
                    onChanged: _onStatusFilterChanged,
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
      return Center(
        child: Text(
          _search.isEmpty
              ? 'No job posts found.'
              : 'No results for "$_search".',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
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
            title: Text(item.title),
            subtitle: Text(
              '${item.companyName} · ${item.employmentTypeName}'
              '${item.cityName.isNotEmpty ? ' · ${item.cityName}' : ''}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isPaid)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: const Text('Featured', style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.amber.shade100,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isActive
                        ? 'Active until ${DateFormat('dd.MM.yyyy').format(item.expiryDate)}'
                        : 'Expired',
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isActive
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.applicationCount} applications',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _openForm(jobPost: item),
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
