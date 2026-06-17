import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../cities/cities_service.dart';
import 'companies_service.dart';
import 'company_form_dialog.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  static const _pageSize = 10;

  List<Company> _items = [];
  List<City> _cities = [];
  int _page = 1;
  int _totalCount = 0;
  String _search = '';
  bool _loading = true;
  bool _citiesLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _load();
  }

  Future<void> _loadCities() async {
    setState(() => _citiesLoading = true);
    try {
      final cities = await CitiesService.listAll();
      setState(() {
        _cities = cities;
        _citiesLoading = false;
      });
    } catch (_) {
      setState(() => _citiesLoading = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await CompaniesService.list(
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
        _error = 'Unable to load companies from the server.';
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

  Future<void> _openForm({Company? company}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CompanyFormDialog(company: company, cities: _cities),
    );
    if (saved == true) {
      _page = 1;
      await _load();
      if (mounted) {
        showAppSnackBar(
          context,
          company == null
              ? 'Company added successfully.'
              : 'Company updated successfully.',
        );
      }
    }
  }

  Future<void> _delete(Company company) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Company',
      message:
          'Are you sure you want to delete "${company.name}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await CompaniesService.delete(company.id);
      await _load();
      if (mounted) showAppSnackBar(context, 'Company deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This company cannot be deleted because it has existing job posts.'
              : e.message,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = !_citiesLoading && _cities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Tooltip(
              message: canAdd ? '' : 'Add at least one city first.',
              child: ElevatedButton.icon(
                onPressed: canAdd ? () => _openForm() : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Company'),
              ),
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
              hintText: 'Search by company name...',
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
              ? 'No companies found.'
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
              backgroundImage:
                  (item.logoUrl != null && item.logoUrl!.isNotEmpty)
                      ? NetworkImage('${ApiConfig.baseUrl}${item.logoUrl}')
                      : null,
              child: (item.logoUrl == null || item.logoUrl!.isEmpty)
                  ? const Icon(Icons.business_outlined)
                  : null,
            ),
            title: Text(item.name),
            subtitle: Text(item.cityName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _openForm(company: item),
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
