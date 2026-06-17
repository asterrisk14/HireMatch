import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import '../application_statuses/application_statuses_service.dart';
import 'applications_service.dart';

class ApplicationStatusDialog extends StatefulWidget {
  final Application application;
  final List<ApplicationStatus> statuses;

  const ApplicationStatusDialog({
    super.key,
    required this.application,
    required this.statuses,
  });

  @override
  State<ApplicationStatusDialog> createState() =>
      _ApplicationStatusDialogState();
}

class _ApplicationStatusDialogState extends State<ApplicationStatusDialog> {
  late int? _selectedStatusId;
  bool _saving = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _selectedStatusId = widget.application.applicationStatusId;
  }

  Future<void> _save() async {
    if (_selectedStatusId == null) return;
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      await ApplicationsService.updateStatus(
        widget.application.id,
        _selectedStatusId!,
      );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DialogHeader(title: 'Update Application Status'),
              const SizedBox(height: 8),
              Text(
                '${widget.application.candidateFullName} → ${widget.application.jobPostTitle}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedStatusId,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: widget.statuses
                    .map(
                      (s) =>
                          DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatusId = value),
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
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
