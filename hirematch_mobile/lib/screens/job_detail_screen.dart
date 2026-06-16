import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/favoruites_provider.dart';
import '../theme.dart';
import '../models/job_post.dart';
import '../services/job_service.dart';
import '../providers/auth_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final JobPost job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final JobService _jobService = JobService();

  bool _hasApplied = false;
  bool _checkingStatus = true;
  bool _applying = false;
  String? _selectedFileName;
  String? _selectedFilePath;
  String? _message;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    final candidateId = auth.user?.id;

    bool applied = false;
    if (candidateId != null) {
      try {
        applied = await _jobService.hasApplied(candidateId, widget.job.id);
      } catch (_) {}
    }

    setState(() {
      _hasApplied = applied;
      _checkingStatus = false;
    });
  }

  Future<void> _toggleSave() async {
    final candidateId = context.read<AuthProvider>().user?.id;
    if (candidateId == null) return;
    await context.read<FavouritesProvider>().toggle(candidateId, widget.job.id);
  }

  Future<void> _pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _apply() async {
    final auth = context.read<AuthProvider>();
    final candidateId = auth.user?.id;
    if (candidateId == null) return;

    if (_selectedFilePath == null) {
      setState(() => _message = 'Please attach your CV before applying.');
      return;
    }

    setState(() {
      _applying = true;
      _message = null;
    });

    try {
      await _jobService.applyToJob(
        jobPostId: widget.job.id,
        cvFilePath: _selectedFilePath,
      );
      setState(() {
        _hasApplied = true;
        _applying = false;
        _message = 'Application submitted successfully!';
      });
    } catch (e) {
      setState(() {
        _applying = false;
        _message = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final favourites = context.watch<FavouritesProvider>();
    final isSaved = favourites.isFavourite(job.id);

    return Scaffold(
      backgroundColor: AppColors.tealMain,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: job.companyLogoUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(job.companyLogoUrl, fit: BoxFit.cover),
                  )
                      : Center(
                    child: Text(
                      job.companyName.isNotEmpty ? job.companyName.substring(0, 1) : '?',
                      style: const TextStyle(
                          color: AppColors.tealDark, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _infoRow('📍', 'Location', job.location.isNotEmpty ? job.location : '—'),
            _infoRow('🏢', 'Company', job.companyName.isNotEmpty ? job.companyName : '—'),
            _infoRow('📅', 'Posted', DateFormat('dd.MM.yyyy').format(job.createdAt)),
            _infoRow('💼', 'Employment Type', job.employmentTypeName.isNotEmpty ? job.employmentTypeName : '—'),
            if (job.industryName.isNotEmpty) _infoRow('🏷️', 'Industry', job.industryName),
            if (job.compensation.isNotEmpty) _infoRow('💰', 'Compensation', job.compensation),
            _infoRow('⏰', 'Deadline', DateFormat('dd.MM.yyyy').format(job.expiryDate)),

            const SizedBox(height: 18),
            const Divider(color: Colors.white30),
            const SizedBox(height: 18),

            if (job.description.isNotEmpty) ...[
              const Text(
                '📝 Description',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 22),
            ],

            const Text(
              '📎 How to Apply',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Attach your CV and click the button below to apply. '
                  'We\'d love to get to know you!',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 14),

            if (!_hasApplied) ...[
              GestureDetector(
                onTap: _pickCV,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.4), style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedFileName ?? 'Attach your CV (PDF, DOC)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            if (_message != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_hasApplied || _applying || _checkingStatus) ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasApplied ? Colors.white.withOpacity(0.3) : AppColors.tealDark,
                  disabledBackgroundColor: Colors.white.withOpacity(0.3),
                ),
                icon: _applying
                    ? const SizedBox(
                  height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Icon(_hasApplied ? Icons.check_circle : Icons.send, color: Colors.white, size: 18),
                label: Text(
                  _hasApplied ? 'Already Applied' : (_applying ? 'Submitting...' : 'Apply Now'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Center(
              child: TextButton.icon(
                onPressed: _toggleSave,
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  isSaved ? 'Saved' : 'Save for later',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5),
          children: [
            TextSpan(text: '$emoji '),
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(color: Colors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }
}