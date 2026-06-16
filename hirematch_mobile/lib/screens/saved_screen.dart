import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/job_service.dart';
import '../services/saved_jobs_service.dart';
import '../providers/auth_provider.dart';
import '../providers/favoruites_provider.dart';
import 'job_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final JobService _jobService = JobService();
  List<Map<String, dynamic>> _applications = [];
  bool _loadingApplications = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final candidateId = context.read<AuthProvider>().user?.id;
    if (candidateId == null) {
      setState(() => _loadingApplications = false);
      return;
    }

    await context.read<FavouritesProvider>().load(candidateId);

    try {
      final applications = await _jobService.getMyApplications(candidateId);
      setState(() {
        _applications = applications;
        _loadingApplications = false;
      });
    } catch (_) {
      setState(() => _loadingApplications = false);
    }
  }

  Future<void> _removeFavourite(int jobPostId) async {
    final candidateId = context.read<AuthProvider>().user?.id;
    if (candidateId == null) return;
    await context.read<FavouritesProvider>().toggle(candidateId, jobPostId);
  }

  @override
  Widget build(BuildContext context) {
    final favourites = context.watch<FavouritesProvider>();

    return Scaffold(
      backgroundColor: AppColors.tealMain,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.tealDark,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Saved: Jobs you\'ve saved for later',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (!favourites.loaded)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (favourites.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'You have no saved jobs yet.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                )
              else
                ...favourites.items.map((fav) => _FavouriteTile(
                  favourite: fav,
                  onRemove: () => _removeFavourite(fav.jobPostId),
                  onTap: () async {
                    try {
                      final job = await _jobService.getJobById(fav.jobPostId);
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                      );
                    } catch (_) {}
                  },
                )),
              const SizedBox(height: 24),
              const Text(
                'Applied: Jobs you\'ve already applied to',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_loadingApplications)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (_applications.isEmpty)
                Text(
                  'You haven\'t applied to any jobs yet.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                )
              else
                ..._applications.map((app) => _AppliedTile(application: app)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavouriteTile extends StatelessWidget {
  final FavouriteItem favourite;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavouriteTile({required this.favourite, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitle = [favourite.employmentTypeName, favourite.location]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A3535),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: favourite.companyLogoUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  favourite.companyLogoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _logoFallback(),
                ),
              )
                  : _logoFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favourite.jobPostTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        favourite.jobPostTitle.isNotEmpty ? favourite.jobPostTitle.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(color: Color(0xFF0E7C7C), fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class _AppliedTile extends StatelessWidget {
  final Map<String, dynamic> application;
  const _AppliedTile({required this.application});

  @override
  Widget build(BuildContext context) {
    final title = application['jobPostTitle'] ?? '';
    final companyName = application['companyName'] ?? '';
    final logoUrl = application['companyLogoUrl'] ?? '';
    final status = application['applicationStatusName'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3535),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: (logoUrl as String).isNotEmpty
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (companyName.toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    companyName,
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
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
        style: const TextStyle(color: Color(0xFF0E7C7C), fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}