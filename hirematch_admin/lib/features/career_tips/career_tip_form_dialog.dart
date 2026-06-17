import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/common_widgets.dart';
import 'career_tips_service.dart';

class CareerTipFormDialog extends StatefulWidget {
  final CareerTip? careerTip;
  const CareerTipFormDialog({super.key, this.careerTip});

  @override
  State<CareerTipFormDialog> createState() => _CareerTipFormDialogState();
}

class _CareerTipFormDialogState extends State<CareerTipFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _iconController;
  bool _saving = false;
  String? _serverError;

  bool get _isEditing => widget.careerTip != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.careerTip?.title ?? '');
    _contentController = TextEditingController(
      text: widget.careerTip?.content ?? '',
    );
    _iconController = TextEditingController(
      text: widget.careerTip?.icon ?? '💡',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Title is required.';
    if (trimmed.length > 150) return 'Title can be at most 150 characters.';
    return null;
  }

  String? _validateContent(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Content is required.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final icon = _iconController.text.trim().isEmpty
          ? '💡'
          : _iconController.text.trim();
      if (_isEditing) {
        await CareerTipsService.update(widget.careerTip!.id, title, content, icon);
      } else {
        await CareerTipsService.create(title, content, icon);
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
        constraints: const BoxConstraints(maxWidth: 480),
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
                  title: _isEditing ? 'Edit Career Tip' : 'New Career Tip',
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _iconController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Icon',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: _validateContent,
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
