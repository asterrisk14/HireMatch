import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../cities/cities_service.dart';
import 'companies_service.dart';

class CompanyFormDialog extends StatefulWidget {
  final Company? company;
  final List<City> cities;

  const CompanyFormDialog({super.key, this.company, required this.cities});

  @override
  State<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _registrationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  int? _selectedCityId;
  bool _saving = false;
  String? _serverError;

  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _addressController = TextEditingController(
      text: widget.company?.address ?? '',
    );
    _registrationController = TextEditingController(
      text: widget.company?.registrationNumber ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.company?.description ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.company?.website ?? '',
    );
    _selectedCityId = widget.company?.cityId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _registrationController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldLabel) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldLabel is required.';
    return null;
  }

  String? _validateWebsite(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final urlRegex = RegExp(r'^https?:\/\/[^\s]+\.[^\s]+$');
    if (!urlRegex.hasMatch(trimmed)) {
      return 'Enter a valid URL, e.g. https://example.com';
    }
    return null;
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _selectedCityId == null) {
      setState(() {});
      return;
    }
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      final registration = _registrationController.text.trim();
      final description = _descriptionController.text.trim();
      final website = _websiteController.text.trim();

      if (_isEditing) {
        await CompaniesService.update(
          id: widget.company!.id,
          name: name,
          address: address,
          cityId: _selectedCityId!,
          registrationNumber: registration,
          description: description.isEmpty ? null : description,
          website: website.isEmpty ? null : website,
        );
      } else {
        await CompaniesService.create(
          name: name,
          address: address,
          cityId: _selectedCityId!,
          registrationNumber: registration,
          description: description.isEmpty ? null : description,
          website: website.isEmpty ? null : website,
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
    final showCityError = _selectedCityId == null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
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
                    title: _isEditing ? 'Edit Company' : 'New Company',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validateRequired(v, 'Company name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validateRequired(v, 'Address'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCityId,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.cities
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name}, ${c.countryName}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCityId = value),
                  ),
                  if (showCityError) ...[
                    const SizedBox(height: 6),
                    Text(
                      'City is required.',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _registrationController,
                    decoration: const InputDecoration(
                      labelText: 'Registration Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validateRequired(v, 'Registration number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website (optional)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateWebsite,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (_serverError != null) ...[
                    const SizedBox(height: 12),
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
