import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/job_post.dart';
import '../theme.dart';
import '../models/candidate.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Candidate candidate;
  const EditProfileScreen({super.key, required this.candidate});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final JobService _jobService = JobService();
  final LocationService _locationService = LocationService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _currentTitleController;
  late TextEditingController _yearsController;
  late TextEditingController _summaryController;
  late TextEditingController _linkedInController;
  late TextEditingController _portfolioController;

  late Set<String> _selectedSkills;
  final List<String> _extraSkills = [];

  List<Country> _countries = [];
  List<City> _cities = [];
  int? _selectedCountryId;
  int? _selectedCityId;
  bool _loadingLocations = true;

  List<Industry> _industries = [];
  List<EmploymentType> _employmentTypes = [];
  int? _selectedIndustryId;
  int? _selectedEmploymentTypeId;

  bool _saving = false;
  bool _uploadingPicture = false;
  bool _uploadingCv = false;
  String? _error;
  String? _newProfilePictureUrl;
  String? _newCvUrl;
  String? _phoneError;

  static final RegExp _phoneRegex = RegExp(r'^(\+387|0)6[0-9]{7}$');

  static const List<String> _availableSkills = [
    'Leadership', 'Teamwork', 'Communication', 'Analytical Thinking',
    'Creativity', 'Problem-solving', 'Human Resources', 'Time Management',
    'Project Management', 'Negotiation', 'Data Analysis', 'Marketing',
    'Data Visualization', 'Research Skills', 'Cybersecurity', 'Public Speaking',
    'Copywriting', 'Business Development', '.NET', 'Angular', 'SQL Server',
    'JavaScript', 'TypeScript', 'C#', 'Customer Service', 'Sales', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.candidate;
    _firstNameController = TextEditingController(text: c.firstName);
    _lastNameController = TextEditingController(text: c.lastName);
    _phoneController = TextEditingController(text: c.phone);
    _currentTitleController = TextEditingController(text: c.currentTitle);
    _yearsController = TextEditingController(text: c.yearsOfExperience > 0 ? c.yearsOfExperience.toString() : '');
    _summaryController = TextEditingController(text: c.summary);
    _linkedInController = TextEditingController(text: c.linkedInUrl);
    _portfolioController = TextEditingController(text: c.portfolioUrl);
    _selectedSkills = {...c.skills};
    _selectedCountryId = c.countryId;
    _selectedCityId = c.cityId;
    _selectedIndustryId = c.preferredIndustryId;
    _selectedEmploymentTypeId = c.preferredEmploymentTypeId;

    for (final s in c.skills) {
      if (!_availableSkills.contains(s)) _extraSkills.add(s);
    }

    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final countries = await _locationService.getCountries();
      final industries = await _jobService.getIndustries();
      final types = await _jobService.getEmploymentTypes();
      setState(() {
        _countries = countries;
        _industries = industries;
        _employmentTypes = types;
      });

      if (_selectedCountryId != null) {
        final cities = await _locationService.getCities(_selectedCountryId!);
        setState(() {
          _cities = cities;
          _loadingLocations = false;
        });
      } else {
        setState(() => _loadingLocations = false);
      }
    } catch (e) {
      setState(() => _loadingLocations = false);
    }
  }

  Future<void> _onCountryChanged(int? countryId) async {
    setState(() {
      _selectedCountryId = countryId;
      _selectedCityId = null;
      _cities = [];
    });
    if (countryId == null) return;
    try {
      final cities = await _locationService.getCities(countryId);
      setState(() => _cities = cities);
    } catch (_) {}
  }

  bool _validatePhone() {
    final phone = _phoneController.text.trim();
    if (!_phoneRegex.hasMatch(phone)) {
      setState(() => _phoneError = 'Enter a valid phone number (e.g. 061234567)');
      return false;
    }
    setState(() => _phoneError = null);
    return true;
  }

  Future<void> _pickProfilePicture() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;

    setState(() => _uploadingPicture = true);
    try {
      final updated = await _jobService.uploadProfilePicture(widget.candidate.id, result.files.single.path!);
      setState(() {
        _newProfilePictureUrl = updated.profilePictureUrl;
        _uploadingPicture = false;
      });
    } catch (e) {
      setState(() => _uploadingPicture = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload picture: $e')),
        );
      }
    }
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _uploadingCv = true);
    try {
      final updated = await _jobService.uploadCv(widget.candidate.id, result.files.single.path!);
      setState(() {
        _newCvUrl = updated.cvUrl;
        _uploadingCv = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV uploaded successfully!')),
        );
      }
    } catch (e) {
      setState(() => _uploadingCv = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload CV: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_validatePhone()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _jobService.updateCandidate(
        id: widget.candidate.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: widget.candidate.email,
        phone: _phoneController.text.trim(),
        countryId: _selectedCountryId,
        cityId: _selectedCityId,
        currentTitle: _currentTitleController.text.trim(),
        yearsOfExperience: int.tryParse(_yearsController.text.trim()) ?? 0,
        summary: _summaryController.text.trim(),
        skills: _selectedSkills.toList(),
        linkedInUrl: _linkedInController.text.trim(),
        portfolioUrl: _portfolioController.text.trim(),
      );

      // Spremi preferencije za recommender
      await _jobService.updatePreferences(
        candidateId: widget.candidate.id,
        preferredIndustryId: _selectedIndustryId,
        preferredEmploymentTypeId: _selectedEmploymentTypeId,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Failed to save changes. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pictureUrl = _newProfilePictureUrl ?? widget.candidate.profilePictureUrl;
    final fullPictureUrl = pictureUrl.isNotEmpty ? '${ApiConfig.baseUrl}$pictureUrl' : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.tealLight,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: fullPictureUrl != null
                          ? Image.network(
                        fullPictureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: AppColors.tealMain),
                      )
                          : const Icon(Icons.person, size: 40, color: AppColors.tealMain),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploadingPicture ? null : _pickProfilePicture,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.tealDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _uploadingPicture
                            ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) {
                if (_phoneError != null) _validatePhone();
              },
              decoration: InputDecoration(labelText: 'Phone', errorText: _phoneError),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _currentTitleController,
              decoration: const InputDecoration(
                labelText: 'Current title / Occupation',
                hintText: 'e.g. Junior Software Developer',
              ),
            ),
            const SizedBox(height: 14),

            if (_loadingLocations)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else ...[
              DropdownButtonFormField<int>(
                value: _selectedCountryId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Country'),
                items: _countries
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: _onCountryChanged,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _selectedCityId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'City'),
                items: _cities
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCityId = value),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _selectedIndustryId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Preferred industry'),
                items: _industries
                    .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedIndustryId = value),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _selectedEmploymentTypeId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Preferred work type'),
                items: _employmentTypes
                    .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedEmploymentTypeId = value),
              ),
            ],
            const SizedBox(height: 14),

            TextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Years of experience'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _summaryController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Summary',
                hintText: 'Tell us a bit about yourself...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _linkedInController,
              decoration: const InputDecoration(labelText: 'LinkedIn URL'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _portfolioController,
              decoration: const InputDecoration(labelText: 'Portfolio URL'),
            ),

            const SizedBox(height: 20),
            const Text(
              'Skills',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [..._availableSkills, ..._extraSkills].map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSkills.remove(skill);
                      } else {
                        _selectedSkills.add(skill);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.tealDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.tealDark : AppColors.border),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              'CV / Resume',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _uploadingCv ? null : _pickCv,
              icon: _uploadingCv
                  ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file, size: 18),
              label: Text(
                (_newCvUrl ?? widget.candidate.cvUrl).isNotEmpty ? 'Replace CV' : 'Upload CV (PDF, DOC)',
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Save changes'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}