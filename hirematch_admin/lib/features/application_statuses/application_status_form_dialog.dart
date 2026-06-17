import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'application_statuses_service.dart';

class ApplicationStatusFormDialog extends StatefulWidget {
  final ApplicationStatus? applicationStatus;
  const ApplicationStatusFormDialog({super.key, this.applicationStatus});

  @override
  State<ApplicationStatusFormDialog> createState() =>
      _ApplicationStatusFormDialogState();
}

class _ApplicationStatusFormDialogState
    extends State<ApplicationStatusFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _saving = false;
  String? _serverError;

  bool get _isEditing => widget.applicationStatus != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.applicationStatus?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Status name is required.';
    if (trimmed.length < 2) return 'Name must be at least 2 characters.';
    if (trimmed.length > 50) return 'Name can be at most 50 characters.';
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
        await ApplicationStatusesService.update(
          widget.applicationStatus!.id,
          name,
        );
      } else {
        await ApplicationStatusesService.create(name);
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
                DialogHeader(
                  title: _isEditing
                      ? 'Edit Application Status'
                      : 'New Application Status',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Status Name',
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
