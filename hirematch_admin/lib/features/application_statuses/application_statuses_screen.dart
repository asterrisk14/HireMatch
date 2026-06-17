import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'application_statuses_service.dart';
import 'application_status_form_dialog.dart';

class ApplicationStatusesScreen extends StatefulWidget {
  const ApplicationStatusesScreen({super.key});

  @override
  State<ApplicationStatusesScreen> createState() =>
      _ApplicationStatusesScreenState();
}

class _ApplicationStatusesScreenState
    extends State<ApplicationStatusesScreen> {
  static const _pageSize = 10;

  List<ApplicationStatus> _items = [];
  int _page = 1;
  int _totalCount = 0;
  String _search = '';
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
      final result = await ApplicationStatusesService.list(
        search: _search,
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
        _error = 'Unable to load application statuses from the server.';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _search = value;
    _page = 1;
    _load();
  }

  void _onPageChanged(int page) {
    _page = page;
    _load();
  }

  Future<void> _openForm({ApplicationStatus? applicationStatus}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          ApplicationStatusFormDialog(applicationStatus: applicationStatus),
    );
    if (saved == true) {
      _page = 1;
      await _load();
      if (mounted) {
        showAppSnackBar(
          context,
          applicationStatus == null
              ? 'Application status added successfully.'
              : 'Application status updated successfully.',
        );
      }
    }
  }

  Future<void> _delete(ApplicationStatus applicationStatus) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Application Status',
      message:
          'Are you sure you want to delete "${applicationStatus.name}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await ApplicationStatusesService.delete(applicationStatus.id);
      await _load();
      if (mounted) {
        showAppSnackBar(context, 'Application status deleted successfully.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This status cannot be deleted because it is used by existing applications.'
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
        title: const Text('Application Statuses'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Status'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchField(
              hintText: 'Search by status name...',
              onChanged: _onSearchChanged,
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
              ? 'No application statuses found.'
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
            title: Text(item.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _openForm(applicationStatus: item),
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
