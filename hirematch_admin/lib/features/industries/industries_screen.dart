import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'industries_service.dart';
import 'industry_form_dialog.dart';

class IndustriesScreen extends StatefulWidget {
  const IndustriesScreen({super.key});

  @override
  State<IndustriesScreen> createState() => _IndustriesScreenState();
}

class _IndustriesScreenState extends State<IndustriesScreen> {
  static const _pageSize = 10;

  List<Industry> _industries = [];
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
      final result = await IndustriesService.list(
        search: _search,
        page: _page,
        pageSize: _pageSize,
      );
      setState(() {
        _industries = result.result;
        _totalCount = result.totalCount;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to load industries from the server.';
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

  Future<void> _openForm({Industry? industry}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => IndustryFormDialog(industry: industry),
    );
    if (saved == true) {
      _page = 1;
      await _load();
      if (mounted) {
        showAppSnackBar(
          context,
          industry == null
              ? 'Industry added successfully.'
              : 'Industry updated successfully.',
        );
      }
    }
  }

  Future<void> _delete(Industry industry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Industry',
      message:
          'Are you sure you want to delete the industry "${industry.name}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await IndustriesService.delete(industry.id);
      await _load();
      if (mounted) showAppSnackBar(context, 'Industry deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This industry cannot be deleted because it is used by existing companies or job posts.'
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
        title: const Text('Industries'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Industry'),
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
              hintText: 'Search by industry name...',
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
    if (_industries.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty
              ? 'No industries found.'
              : 'No results for "$_search".',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return Card(
      child: ListView.separated(
        itemCount: _industries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final industry = _industries[index];
          return ListTile(
            title: Text(industry.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _openForm(industry: industry),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _delete(industry),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
