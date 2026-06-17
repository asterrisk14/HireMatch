import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'candidate_detail_screen.dart';
import 'talent_pool_service.dart';

class TalentPoolScreen extends StatefulWidget {
  const TalentPoolScreen({super.key});

  @override
  State<TalentPoolScreen> createState() => _TalentPoolScreenState();
}

class _TalentPoolScreenState extends State<TalentPoolScreen> {
  static const _pageSize = 10;

  List<Candidate> _items = [];
  int _page = 1;
  int _totalCount = 0;
  String _search = '';
  bool? _isPremiumFilter;
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
      final result = await CandidatesService.list(
        search: _search,
        isPremium: _isPremiumFilter,
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
        _error = 'Unable to load candidates from the server.';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _search = value;
    _page = 1;
    _load();
  }

  void _onPremiumFilterChanged(bool? value) {
    _isPremiumFilter = value;
    _page = 1;
    _load();
  }

  void _onPageChanged(int page) {
    _page = page;
    _load();
  }

  void _viewDetails(Candidate candidate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CandidateDetailScreen(candidate: candidate),
      ),
    );
  }

  Future<void> _delete(Candidate candidate) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Candidate',
      message:
          'Are you sure you want to delete "${candidate.fullName}"? '
          'This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await CandidatesService.delete(candidate.id);
      await _load();
      if (mounted) showAppSnackBar(context, 'Candidate deleted successfully.');
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          e.isConflict
              ? 'This candidate cannot be deleted because they have existing applications.'
              : e.message,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Talent Pool')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SearchField(
                  hintText: 'Search by name, title, or skill...',
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<bool?>(
                    initialValue: _isPremiumFilter,
                    decoration: InputDecoration(
                      labelText: 'Plan',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: true, child: Text('Premium')),
                      DropdownMenuItem(value: false, child: Text('Free')),
                    ],
                    onChanged: _onPremiumFilterChanged,
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
              ? 'No candidates found.'
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
          final hasPicture = item.profilePictureUrl.isNotEmpty;
          return ListTile(
            onTap: () => _viewDetails(item),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: hasPicture
                  ? NetworkImage('${ApiConfig.baseUrl}${item.profilePictureUrl}')
                  : null,
              child: hasPicture ? null : const Icon(Icons.person_outline),
            ),
            title: Text(item.fullName),
            subtitle: Text(
              [
                item.currentTitle,
                [item.cityName, item.countryName]
                    .where((s) => s.isNotEmpty)
                    .join(', '),
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isPremium)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: const Text('Premium', style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.amber.shade100,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'View Details',
                  onPressed: () => _viewDetails(item),
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
