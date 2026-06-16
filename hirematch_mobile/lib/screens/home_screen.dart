import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/job_post.dart';
import '../services/job_service.dart';
import '../services/tips_service.dart';
import '../providers/auth_provider.dart';
import '../providers/favoruites_provider.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';
import 'dart:async';
import '../services/notification_service.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobService _jobService = JobService();
  final TipsService _tipsService = TipsService();
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  Timer? _pollTimer;

  List<JobPost> _jobs = [];
  List<RecommendedJob> _recommended = [];
  List<CareerTip> _tips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadUnreadCount();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadUnreadCount());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (!mounted) return;
    setState(() => _unreadCount = count);
  }

  Future<void> _load() async {
    try {
      final recommended = await _jobService.getRecommended();
      // ignore: avoid_print
      print('RECOMMENDED COUNT: ${recommended.length}');
      for (final r in recommended) {
        // ignore: avoid_print
        print('  - ${r.title} | score=${r.score} | ${r.explanation}');
      }
      // Fallback: ako nema preporuka (npr. korisnik nema preferencija/vještina), pokaži najnovije
      List<JobPost> latest = [];
      if (recommended.isEmpty) {
        final result = await _jobService.getJobPosts(page: 1, pageSize: 3);
        latest = result.result;
      }
      final tips = await _tipsService.getTips();
      final candidateId = context.read<AuthProvider>().user?.id;
      if (candidateId != null) {
        await context.read<FavouritesProvider>().load(candidateId);
      }
      setState(() {
        _recommended = recommended;
        _jobs = latest;
        _tips = tips;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleSave(int jobId) async {
    final candidateId = context.read<AuthProvider>().user?.id;
    if (candidateId == null) return;
    await context.read<FavouritesProvider>().toggle(candidateId, jobId);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final favourites = context.watch<FavouritesProvider>();
    final firstName = user?.firstName ?? '';

    return Scaffold(
      backgroundColor: AppColors.tealMain,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.tealDark,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      firstName.isNotEmpty
                          ? 'Hi $firstName, ready to explore\nnew opportunities today?'
                          : 'Hi there, ready to explore\nnew opportunities today?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                          // Osvježi broj nakon povratka sa ekrana
                          _loadUnreadCount();
                        },
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              _unreadCount > 9 ? '9+' : '$_unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recommended for you',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (_recommended.isNotEmpty)
                ..._recommended.map((rec) => _RecommendedCard(
                  job: rec,
                  isSaved: favourites.isFavourite(rec.id),
                  onSaveToggle: () => _toggleSave(rec.id),
                  onTap: () async {
                    try {
                      final job = await _jobService.getJobById(rec.id);
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                      );
                    } catch (_) {}
                  },
                ))
              else if (_jobs.isNotEmpty)
                  ..._jobs.map((job) => JobCard(
                    job: job,
                    isSaved: favourites.isFavourite(job.id),
                    onSaveToggle: () => _toggleSave(job.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                      );
                    },
                  ))
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No recommendations yet. Add skills and preferences to your profile to get matched.',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
              const SizedBox(height: 16),
              const Text(
                '💡 Quick Career Tips 🚀',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (_tips.isEmpty)
                Text(
                  'No tips available right now.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                )
              else
                ..._tips.map((tip) => _TipTile(tip: tip)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final CareerTip tip;
  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tip.icon} ${tip.title}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.tealDark),
                ),
                const SizedBox(height: 12),
                Text(
                  tip.content,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tip.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tip.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final RecommendedJob job;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final VoidCallback onTap;

  const _RecommendedCard({
    required this.job,
    required this.isSaved,
    required this.onSaveToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [job.employmentTypeName, job.location]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: job.companyLogoUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      job.companyLogoUrl,
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
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0A3535),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job.companyName.isNotEmpty)
                        Text(
                          job.companyName,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7B7B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFF0E7C7C),
                    size: 22,
                  ),
                  onPressed: onSaveToggle,
                ),
              ],
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7B7B)),
                ),
              ),
            const SizedBox(height: 10),
            // "Why recommended" - explainable preporuka
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      job.explanation,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF2E5E3A), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        job.title.isNotEmpty ? job.title.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(color: Color(0xFF0E7C7C), fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}