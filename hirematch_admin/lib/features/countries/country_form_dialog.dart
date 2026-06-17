import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'countries_service.dart';

class CountryFormDialog extends StatefulWidget {
  final Country? country;
  const CountryFormDialog({super.key, this.country});

  @override
  State<CountryFormDialog> createState() => _CountryFormDialogState();
}

class _CountryFormDialogState extends State<CountryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _saving = false;
  String? _serverError;

  bool get _isEditing => widget.country != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.country?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Country name is required.';
    if (trimmed.length < 2) return 'Name must be at least 2 characters.';
    if (trimmed.length > 100) return 'Name can be at most 100 characters.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final name = _nameController.text.trim();
      if (_isEditing) {
        await CountriesService.update(widget.country!.id, name);
      } else {
        await CountriesService.create(name);
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
                DialogHeader(title: _isEditing ? 'Edit Country' : 'New Country'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Country Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
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
    );
  }
}
