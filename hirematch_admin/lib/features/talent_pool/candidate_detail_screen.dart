import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import 'talent_pool_service.dart';

class CandidateDetailScreen extends StatelessWidget {
  final Candidate candidate;
  const CandidateDetailScreen({super.key, required this.candidate});

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this link.')),
      );
    }
  }

  void _contact(BuildContext context) {
    _launch(context, Uri(scheme: 'mailto', path: candidate.email));
  }

  void _openCv(BuildContext context) {
    _launch(context, Uri.parse('${ApiConfig.baseUrl}${candidate.cvUrl}'));
  }

  void _openLink(BuildContext context, String url) {
    final normalized = url.startsWith('http') ? url : 'https://$url';
    _launch(context, Uri.parse(normalized));
  }

  @override
  Widget build(BuildContext context) {
    final hasPicture = candidate.profilePictureUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Candidate Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: hasPicture
                          ? NetworkImage(
                              '${ApiConfig.baseUrl}${candidate.profilePictureUrl}',
                            )
                          : null,
                      child: hasPicture
                          ? null
                          : const Icon(Icons.person_outline, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                candidate.fullName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (candidate.isPremium) ...[
                                const SizedBox(width: 8),
                                Chip(
                                  label: const Text(
                                    'Premium',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.amber.shade100,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ],
                          ),
                          if (candidate.currentTitle.isNotEmpty)
                            Text(
                              candidate.currentTitle,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _contact(context),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Contact via Email'),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DetailRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: candidate.email,
                        ),
                        _DetailRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: candidate.phone,
                        ),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: [
                            candidate.cityName,
                            candidate.countryName,
                          ].where((s) => s.isNotEmpty).join(', '),
                        ),
                        _DetailRow(
                          icon: Icons.work_outline,
                          label: 'Experience',
                          value: '${candidate.yearsOfExperience} years',
                        ),
                        if (candidate.preferredIndustryName.isNotEmpty)
                          _DetailRow(
                            icon: Icons.business_center_outlined,
                            label: 'Preferred Industry',
                            value: candidate.preferredIndustryName,
                          ),
                        if (candidate.preferredEmploymentTypeName.isNotEmpty)
                          _DetailRow(
                            icon: Icons.work_history_outlined,
                            label: 'Preferred Employment Type',
                            value: candidate.preferredEmploymentTypeName,
                          ),
                      ],
                    ),
                  ),
                ),
                if (candidate.summary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(candidate.summary),
                ],
                if (candidate.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Skills',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: candidate.skills
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (candidate.cvUrl.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => _openCv(context),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('View CV'),
                      ),
                    if (candidate.linkedInUrl.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openLink(context, candidate.linkedInUrl),
                        icon: const Icon(Icons.link),
                        label: const Text('LinkedIn'),
                      ),
                    if (candidate.portfolioUrl.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openLink(context, candidate.portfolioUrl),
                        icon: const Icon(Icons.language_outlined),
                        label: const Text('Portfolio'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
