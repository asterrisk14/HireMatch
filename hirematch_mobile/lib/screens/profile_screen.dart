import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models/candidate.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'my_applications_screen.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final JobService _jobService = JobService();
  Candidate? _candidate;
  bool _loading = true;

  bool get _isPremiumUser => context.read<AuthProvider>().user?.isPremium ?? false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final id = auth.user?.id;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final candidate = await _jobService.getCandidateById(id);
      setState(() {
        _candidate = candidate;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openCV() async {
    final cvUrl = _candidate?.cvUrl;
    if (cvUrl == null || cvUrl.isEmpty) return;
    final fullUrl = '${ApiConfig.baseUrl}$cvUrl';
    await launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication);
  }

  Future<void> _editProfile() async {
    if (_candidate == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(candidate: _candidate!)),
    );
    if (result == true) {
      _load();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidate = _candidate;

    return Scaffold(
      backgroundColor: AppColors.tealMain,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
          onRefresh: _load,
          color: AppColors.tealDark,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.lock_outline, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                    tooltip: 'Change password',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: _editProfile,
                    tooltip: 'Edit profile',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: _buildAvatar(candidate),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  '${candidate?.firstName ?? ''} ${candidate?.lastName ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (candidate?.currentTitle.isNotEmpty == true)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      candidate!.currentTitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              _infoRow('📧', 'Email', candidate?.email ?? '—'),
              _infoRow('📍', 'Location', candidate?.locationDisplay.isNotEmpty == true ? candidate!.locationDisplay : '—'),
              _infoRow('📞', 'Phone', candidate?.phone.isNotEmpty == true ? candidate!.phone : '—'),
              if (candidate != null && candidate.yearsOfExperience > 0)
                _infoRow('🎯', 'Experience', '${candidate.yearsOfExperience} years'),
              if (candidate?.preferredIndustryName.isNotEmpty == true)
                _infoRow('🏷️', 'Preferred industry', candidate!.preferredIndustryName),
              if (candidate?.preferredEmploymentTypeName.isNotEmpty == true)
                _infoRow('💼', 'Preferred work type', candidate!.preferredEmploymentTypeName),
              if (candidate?.summary.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                const Text(
                  '📝 Summary',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  candidate!.summary,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.5),
                ),
              ],

              if (candidate != null && candidate.skills.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  '🛠️ Skills',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: candidate.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ],

              if (candidate?.linkedInUrl.isNotEmpty == true || candidate?.portfolioUrl.isNotEmpty == true) ...[
                const SizedBox(height: 18),
                const Text(
                  '🔗 Links',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                if (candidate?.linkedInUrl.isNotEmpty == true)
                  Text('LinkedIn: ${candidate!.linkedInUrl}',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                if (candidate?.portfolioUrl.isNotEmpty == true)
                  Text('Portfolio: ${candidate!.portfolioUrl}',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    ).then((_) => _load());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD24D),
                    foregroundColor: const Color(0xFF6B5200),
                  ),
                  icon: const Icon(Icons.star, color: Color(0xFF6B5200)),
                  label: Text(
                    candidate != null && _isPremiumUser ? 'Premium active ⭐' : 'Go Premium ⭐',
                    style: const TextStyle(color: Color(0xFF6B5200), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.tealDark,
                  ),
                  icon: const Icon(Icons.assignment_outlined, color: AppColors.tealDark),
                  label: const Text('My applications', style: TextStyle(color: AppColors.tealDark)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: candidate?.cvUrl.isNotEmpty == true ? _openCV : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.white.withOpacity(0.2),
                  ),
                  icon: const Icon(Icons.description_outlined, color: Colors.white),
                  label: Text(
                    candidate?.cvUrl.isNotEmpty == true ? 'My CV' : 'No CV uploaded yet',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Upload your CV when applying to a job',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Candidate? candidate) {
    final pictureUrl = candidate?.profilePictureUrl ?? '';
    final initials =
        '${candidate?.firstName.isNotEmpty == true ? candidate!.firstName[0] : ''}${candidate?.lastName.isNotEmpty == true ? candidate!.lastName[0] : ''}';

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: pictureUrl.isNotEmpty
            ? Image.network(
          '${ApiConfig.baseUrl}$pictureUrl',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(initials),
        )
            : _initialsAvatar(initials),
      ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(color: AppColors.tealDark, fontSize: 30, fontWeight: FontWeight.bold),
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