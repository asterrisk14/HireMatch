import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../countries/countries_service.dart';
import 'cities_service.dart';

class CityFormDialog extends StatefulWidget {
  final City? city;
  final List<Country> countries;

  const CityFormDialog({super.key, this.city, required this.countries});

  @override
  State<CityFormDialog> createState() => _CityFormDialogState();
}

class _CityFormDialogState extends State<CityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  int? _selectedCountryId;
  bool _saving = false;
  String? _serverError;

  bool get _isEditing => widget.city != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.city?.name ?? '');
    _selectedCountryId = widget.city?.countryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'City name is required.';
    if (trimmed.length < 2) return 'Name must be at least 2 characters.';
    if (trimmed.length > 100) return 'Name can be at most 100 characters.';
    return null;
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _selectedCountryId == null) {
      setState(() {});
      return;
    }
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final name = _nameController.text.trim();
      if (_isEditing) {
        await CitiesService.update(widget.city!.id, name, _selectedCountryId!);
      } else {
        await CitiesService.create(name, _selectedCountryId!);
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
    final showCountryError = _selectedCountryId == null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DialogHeader(title: _isEditing ? 'Edit City' : 'New City'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'City Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedCountryId,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.countries
                      .map(
                        (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCountryId = value),
                ),
                if (showCountryError) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Country is required.',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ],
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
    );
  }
}
