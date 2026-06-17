import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../countries/countries_service.dart';
import 'cities_service.dart';
import 'city_form_dialog.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  static const _pageSize = 10;

  List<City> _items = [];
  List<Country> _countries = [];
  int _page = 1;
  int _totalCount = 0;
  int? _filterCountryId;
  bool _loading = true;
  bool _countriesLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _load();
  }

  Future<void> _loadCountries() async {
    setState(() => _countriesLoading = true);
    try {
      final countries = await CountriesService.listAll();
      setState(() {
        _countries = countries;
        _countriesLoading = false;
      });
    } catch (_) {
      setState(() => _countriesLoading = false);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await CitiesService.list(
        countryId: _filterCountryId,
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
        _error = 'Unable to load cities from the server.';
        _loading = false;
      });
    }
  }

  void _onCountryFilterChanged(int? countryId) {
    _filterCountryId = countryId;
    _page = 1;
    _load();
  }

  void _onPageChanged(int page) {
    _page = page;
    _load();
  }

  Future<void> _openForm({City? city}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => CityFormDialog(city: city, countries: _countries),
    );
    if (saved == true) {
      _page = 1;
      await _load();
      if (mounted) {
        showAppSnackBar(
          context,
          city == null
              ? 'City added successfully.'
              : 'City updated successfully.',
        );
      }
    }
  }

  Future<void> _delete(City city) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete City',
      message:
          'Are you sure you want to delete "${city.name}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await CitiesService.delete(city.id);
      await _load();
      if (mounted) showAppSnackBar(context, 'City deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This city cannot be deleted because it is used by existing companies or job posts.'
              : e.message,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = !_countriesLoading && _countries.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Tooltip(
              message: canAdd ? '' : 'Add at least one country first.',
              child: ElevatedButton.icon(
                onPressed: canAdd ? () => _openForm() : null,
                icon: const Icon(Icons.add),
                label: const Text('Add City'),
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
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<int?>(
                initialValue: _filterCountryId,
                decoration: InputDecoration(
                  labelText: 'Filter by country',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All countries')),
                  ..._countries.map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ),
                ],
                onChanged: _onCountryFilterChanged,
              ),
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
          _filterCountryId == null
              ? 'No cities found.'
              : 'No cities found for the selected country.',
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
            subtitle: Text(item.countryName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _openForm(city: item),
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
