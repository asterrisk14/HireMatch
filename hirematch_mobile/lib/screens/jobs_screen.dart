import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/job_post.dart';
import '../services/job_service.dart';
import '../providers/auth_provider.dart';
import '../providers/favoruites_provider.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobService _jobService = JobService();
  final _keywordController = TextEditingController();

  List<JobPost> _jobs = [];
  List<EmploymentType> _employmentTypes = [];
  int? _selectedEmploymentTypeId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmploymentTypes();
    _search();
  }

  Future<void> _loadEmploymentTypes() async {
    try {
      final types = await _jobService.getEmploymentTypes();
      setState(() => _employmentTypes = types);
    } catch (_) {}
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _jobService.getJobPosts(
        keyword: _keywordController.text.trim(),
        employmentTypeId: _selectedEmploymentTypeId,
        page: 1,
        pageSize: 30,
      );
      setState(() {
        _jobs = result.result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggleSave(int jobId) async {
    final candidateId = context.read<AuthProvider>().user?.id;
    if (candidateId == null) return;
    await context.read<FavouritesProvider>().toggle(candidateId, jobId);
  }

  @override
  Widget build(BuildContext context) {
    final favourites = context.watch<FavouritesProvider>();

    return Scaffold(
      backgroundColor: AppColors.tealMain,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Discover jobs that match\nyour interests',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _keywordController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Enter a keyword (title, description...)',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedEmploymentTypeId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work_outline, color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
                hint: const Text('Select employment type', style: TextStyle(color: AppColors.textMuted)),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('All employment types')),
                  ..._employmentTypes.map((type) => DropdownMenuItem<int>(
                    value: type.id,
                    child: Text(type.name),
                  )),
                ],
                onChanged: (value) => setState(() => _selectedEmploymentTypeId = value),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _search,
                child: const Text('SEARCH'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Available positions',
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
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.white)),
              )
            else if (_jobs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No jobs found. Try a different search.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                )
              else
                ..._jobs.map((job) => JobCard(
                  job: job,
                  isSaved: favourites.isFavourite(job.id),
                  onSaveToggle: () => _toggleSave(job.id),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}