import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/job_service.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation.dart';
import '../../models/job_post.dart';

class OnboardingSkillsScreen extends StatefulWidget {
  final List<int> selectedIndustryIds;
  final List<int> selectedEmploymentTypeIds;

  const OnboardingSkillsScreen({
    super.key,
    required this.selectedIndustryIds,
    required this.selectedEmploymentTypeIds,
  });

  @override
  State<OnboardingSkillsScreen> createState() => _OnboardingSkillsScreenState();
}

class _OnboardingSkillsScreenState extends State<OnboardingSkillsScreen> {
  final JobService _jobService = JobService();
  bool _saving = false;
  bool _loading = true;
  String? _error;
  List<Skill> _availableSkills = [];
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final skills = await _jobService.getSkills();
      setState(() {
        _availableSkills = skills;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load skills. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final candidateId = auth.user?.id;

    if (candidateId != null) {
      for (final skill in _availableSkills.where(
        (s) => _selectedIds.contains(s.id),
      )) {
        try {
          await _jobService.addUserSkill(candidateId, skill.name);
        } catch (_) {}
      }

      try {
        await _jobService.updatePreferences(
          candidateId: candidateId,
          preferredIndustryId: widget.selectedIndustryIds.isNotEmpty
              ? widget.selectedIndustryIds.first
              : null,
          preferredEmploymentTypeId: widget.selectedEmploymentTypeIds.isNotEmpty
              ? widget.selectedEmploymentTypeIds.first
              : null,
        );
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepBar(step: 3),
              const SizedBox(height: 20),
              const Text(
                'Which skills would you like to highlight?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tealDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select the skills that best represent you',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _availableSkills.isEmpty
                    ? const Center(child: Text('No skills available.'))
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableSkills.map((skill) {
                            final isSelected = _selectedIds.contains(skill.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(skill.id);
                                  } else {
                                    _selectedIds.add(skill.id);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.tealDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.tealDark
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  skill.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedIds.isEmpty || _saving || _loading)
                      ? null
                      : _finish,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.tealMain : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
