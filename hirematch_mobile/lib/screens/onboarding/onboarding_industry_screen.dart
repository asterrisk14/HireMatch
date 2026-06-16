import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/job_post.dart';
import '../../services/job_service.dart';
import 'onboarding_worktype_screen.dart';

class OnboardingIndustryScreen extends StatefulWidget {
  const OnboardingIndustryScreen({super.key});

  @override
  State<OnboardingIndustryScreen> createState() => _OnboardingIndustryScreenState();
}

class _OnboardingIndustryScreenState extends State<OnboardingIndustryScreen> {
  final JobService _jobService = JobService();
  List<Industry> _industries = [];
  final Set<int> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final industries = await _jobService.getIndustries();
      setState(() {
        _industries = industries;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _next() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingWorkTypeScreen(selectedIndustryIds: _selected.toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepIndicator(step: 1),
              const SizedBox(height: 20),
              const Text(
                'What industries interest you?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.tealDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select one or more areas you\'d like to work in',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _industries.map((industry) {
                            final isSelected = _selected.contains(industry.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selected.remove(industry.id);
                                  } else {
                                    _selected.add(industry.id);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.tealDark : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? AppColors.tealDark : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  industry.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
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

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

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
