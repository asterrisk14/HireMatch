import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/job_post.dart';
import '../../services/job_service.dart';
import 'onboarding_skills_screen.dart';

class OnboardingWorkTypeScreen extends StatefulWidget {
  final List<int> selectedIndustryIds;
  const OnboardingWorkTypeScreen({super.key, required this.selectedIndustryIds});

  @override
  State<OnboardingWorkTypeScreen> createState() => _OnboardingWorkTypeScreenState();
}

class _OnboardingWorkTypeScreenState extends State<OnboardingWorkTypeScreen> {
  final JobService _jobService = JobService();
  List<EmploymentType> _types = [];
  final Set<int> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final types = await _jobService.getEmploymentTypes();
      setState(() {
        _types = types;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _next() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingSkillsScreen(
          selectedIndustryIds: widget.selectedIndustryIds,
          selectedEmploymentTypeIds: _selected.toList(),
        ),
      ),
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
              _StepBar(step: 2),
              const SizedBox(height: 20),
              const Text(
                'How do you prefer to work?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.tealDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your preferred employment types',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final type = _types[index];
                          final isSelected = _selected.contains(type.id);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selected.remove(type.id);
                                } else {
                                  _selected.add(type.id);
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.tealLight : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.tealMain : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                                    color: isSelected ? AppColors.tealMain : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    type.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty ? null : _next,
                  child: const Text('Continue'),
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
