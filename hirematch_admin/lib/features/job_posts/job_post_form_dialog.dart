import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../auth/auth_provider.dart';
import '../cities/cities_service.dart';
import '../companies/companies_service.dart';
import '../employment_types/employment_types_service.dart';
import '../industries/industries_service.dart';
import '../skills/skills_service.dart';
import '../work_modes/work_modes_service.dart';
import 'job_posts_service.dart';

class JobPostFormDialog extends StatefulWidget {
  final JobPost? jobPost;
  final int currentUserId;

  const JobPostFormDialog({
    super.key,
    this.jobPost,
    required this.currentUserId,
  });

  @override
  State<JobPostFormDialog> createState() => _JobPostFormDialogState();
}

class _JobPostFormDialogState extends State<JobPostFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _compensationController;

  bool _loadingOptions = true;
  List<Company> _companies = [];
  List<EmploymentType> _employmentTypes = [];
  List<Industry> _industries = [];
  List<City> _cities = [];
  List<WorkMode> _workModes = [];
  List<Skill> _skills = [];

  int? _selectedCompanyId;
  int? _selectedEmploymentTypeId;
  int? _selectedIndustryId;
  int? _selectedCityId;
  int? _selectedWorkModeId;
  DateTime? _selectedExpiryDate;
  final Set<int> _selectedSkillIds = {};

  bool _saving = false;
  String? _serverError;

  bool get _isEditing => widget.jobPost != null;

  @override
  void initState() {
    super.initState();
    final job = widget.jobPost;
    _titleController = TextEditingController(text: job?.title ?? '');
    _descriptionController = TextEditingController(text: job?.description ?? '');
    _compensationController = TextEditingController(text: job?.compensation ?? '');
    _selectedCompanyId = job?.companyId;
    _selectedEmploymentTypeId = job?.employmentTypeId;
    _selectedIndustryId = job?.industryId;
    _selectedCityId = job?.cityId;
    _selectedWorkModeId = job?.workModeId;
    _selectedExpiryDate = job?.expiryDate;
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final results = await Future.wait([
      CompaniesService.listAll(),
      EmploymentTypesService.listAll(),
      IndustriesService.listAll(),
      CitiesService.listAll(),
      WorkModesService.listAll(),
      SkillsService.listAll(),
    ]);
    if (!mounted) return;
    setState(() {
      _companies = results[0] as List<Company>;
      _employmentTypes = results[1] as List<EmploymentType>;
      _industries = results[2] as List<Industry>;
      _cities = results[3] as List<City>;
      _workModes = results[4] as List<WorkMode>;
      _skills = results[5] as List<Skill>;
      _loadingOptions = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _compensationController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldLabel) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldLabel is required.';
    return null;
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  bool get _isFormValid =>
      _selectedCompanyId != null &&
      _selectedEmploymentTypeId != null &&
      (_isEditing || _selectedIndustryId != null) &&
      _selectedExpiryDate != null;

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    if (!formValid || !_isFormValid) {
      setState(() {});
      return;
    }
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final compensation = _compensationController.text.trim();

      if (_isEditing) {
        await JobPostsService.update(
          id: widget.jobPost!.id,
          title: title,
          description: description,
          companyId: _selectedCompanyId!,
          recruiterId: widget.currentUserId,
          employmentTypeId: _selectedEmploymentTypeId!,
          cityId: _selectedCityId,
          workModeId: _selectedWorkModeId,
          compensation: compensation,
          expiryDate: _selectedExpiryDate!,
          skillIds: _selectedSkillIds.toList(),
        );
      } else {
        await JobPostsService.create(
          title: title,
          description: description,
          companyId: _selectedCompanyId!,
          recruiterId: widget.currentUserId,
          employmentTypeId: _selectedEmploymentTypeId!,
          industryId: _selectedIndustryId!,
          cityId: _selectedCityId,
          workModeId: _selectedWorkModeId,
          compensation: compensation,
          expiryDate: _selectedExpiryDate!,
          skillIds: _selectedSkillIds.toList(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _serverError = e.message);
    } catch (_) {
      setState(
        () => _serverError = 'Unable to save data. Please check your connection.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: _loadingOptions
            ? const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DialogHeader(
                          title: _isEditing ? 'Edit Job Post' : 'New Job Post',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Job Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => _validateRequired(v, 'Job title'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => _validateRequired(v, 'Description'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCompanyId,
                          decoration: const InputDecoration(
                            labelText: 'Company',
                            border: OutlineInputBorder(),
                          ),
                          items: _companies
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCompanyId = value),
                        ),
                        if (_selectedCompanyId == null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Company is required.',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _selectedEmploymentTypeId,
                                decoration: const InputDecoration(
                                  labelText: 'Employment Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: _employmentTypes
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.id,
                                        child: Text(e.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => setState(
                                  () => _selectedEmploymentTypeId = value,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Tooltip(
                                message: _isEditing
                                    ? 'Industry cannot be changed after the job post is created.'
                                    : '',
                                child: DropdownButtonFormField<int>(
                                  initialValue: _selectedIndustryId,
                                  decoration: const InputDecoration(
                                    labelText: 'Industry',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _industries
                                      .map(
                                        (i) => DropdownMenuItem(
                                          value: i.id,
                                          child: Text(i.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _isEditing
                                      ? null
                                      : (value) => setState(
                                          () => _selectedIndustryId = value,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedEmploymentTypeId == null ||
                            (!_isEditing && _selectedIndustryId == null)) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Employment type and industry are required.',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _selectedCityId,
                                decoration: const InputDecoration(
                                  labelText: 'City (optional)',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Not specified'),
                                  ),
                                  ..._cities.map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedCityId = value),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                initialValue: _selectedWorkModeId,
                                decoration: const InputDecoration(
                                  labelText: 'Work Mode (optional)',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Not specified'),
                                  ),
                                  ..._workModes.map(
                                    (w) => DropdownMenuItem(
                                      value: w.id,
                                      child: Text(w.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedWorkModeId = value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _compensationController,
                          decoration: const InputDecoration(
                            labelText: 'Compensation',
                            border: OutlineInputBorder(),
                            hintText: 'e.g. 1500-2000 BAM',
                          ),
                          validator: (v) => _validateRequired(v, 'Compensation'),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickExpiryDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Application Deadline',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _selectedExpiryDate != null
                                  ? DateFormat('dd.MM.yyyy').format(_selectedExpiryDate!)
                                  : 'Select a date',
                            ),
                          ),
                        ),
                        if (_selectedExpiryDate == null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Application deadline is required.',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Required Skills (optional)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isEditing)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Text(
                              'Previously assigned skills are not shown here. '
                              'Saving without re-selecting skills will remove '
                              'all skills currently linked to this job post.',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills.map((skill) {
                            final selected = _selectedSkillIds.contains(skill.id);
                            return FilterChip(
                              label: Text(skill.name),
                              selected: selected,
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedSkillIds.add(skill.id);
                                  } else {
                                    _selectedSkillIds.remove(skill.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (_serverError != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _serverError!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _saving ? null : _save,
                              child: _saving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(_isEditing ? 'Save' : 'Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
