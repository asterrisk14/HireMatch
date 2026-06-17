import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'countries_service.dart';
import 'country_form_dialog.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  static const _pageSize = 10;

  List<Country> _items = [];
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
      final result = await CountriesService.list(
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
        _error = 'Unable to load countries from the server.';
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

  Future<void> _openForm({Country? country}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CountryFormDialog(country: country),
    );
    if (saved == true) {
      _page = 1;
      await _load();
      if (mounted) {
        showAppSnackBar(
          context,
          country == null
              ? 'Country added successfully.'
              : 'Country updated successfully.',
        );
      }
    }
  }

  Future<void> _delete(Country country) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Country',
      message:
          'Are you sure you want to delete "${country.name}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await CountriesService.delete(country.id);
      await _load();
      if (mounted) showAppSnackBar(context, 'Country deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This country cannot be deleted because it is used by existing cities or candidates.'
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
        title: const Text('Countries'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Country'),
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
              hintText: 'Search by country name...',
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
              ? 'No countries found.'
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
                  onPressed: () => _openForm(country: item),
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
