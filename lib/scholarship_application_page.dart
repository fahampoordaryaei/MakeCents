import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScholarshipApplicationPage extends StatefulWidget {
  final String title;
  final String provider;
  final double amount;
  final String currency;
  final String description;
  final Color brandColor;
  final ScholarshipApplication? initialDraft;

  const ScholarshipApplicationPage({
    super.key,
    required this.title,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.description,
    required this.brandColor,
    this.initialDraft,
  });

  @override
  State<ScholarshipApplicationPage> createState() =>
      _ScholarshipApplicationPageState();
}

class ScholarshipAttachment {
  final String name;
  final String? path;
  final int? size;

  ScholarshipAttachment({required this.name, this.path, this.size});

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path, 'size': size};
  }

  factory ScholarshipAttachment.fromJson(Map<String, dynamic> json) {
    return ScholarshipAttachment(
      name: json['name'] as String,
      path: json['path'] as String?,
      size: json['size'] as int?,
    );
  }
}

class ScholarshipApplication {
  final String scholarshipTitle;
  final String provider;
  final String description;
  final double amount;
  final String currency;
  final String email;
  final String statement;
  final List<ScholarshipAttachment> attachments;
  final String savedAt;

  ScholarshipApplication({
    required this.scholarshipTitle,
    required this.provider,
    required this.description,
    required this.amount,
    required this.currency,
    required this.email,
    required this.statement,
    required this.attachments,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'scholarshipTitle': scholarshipTitle,
      'provider': provider,
      'description': description,
      'amount': amount,
      'currency': currency,
      'email': email,
      'statement': statement,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'savedAt': savedAt,
    };
  }

  factory ScholarshipApplication.fromJson(Map<String, dynamic> json) {
    return ScholarshipApplication(
      scholarshipTitle: json['scholarshipTitle'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      email: json['email'] as String,
      statement: json['statement'] as String,
      attachments: (json['attachments'] as List<dynamic>)
          .map(
            (item) =>
                ScholarshipAttachment.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      savedAt: json['savedAt'] as String,
    );
  }
}

class _ScholarshipApplicationPageState
    extends State<ScholarshipApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _statementController = TextEditingController();
  final List<ScholarshipAttachment> _attachments = [];
  bool _isLoading = true;
  bool _isSaving = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _statementController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    _prefs = await SharedPreferences.getInstance();
    final savedJson = _prefs.getString('scholarship_applications');

    ScholarshipApplication? existing;
    if (savedJson != null) {
      final items = jsonDecode(savedJson) as List<dynamic>;
      final applications = items
          .map(
            (item) =>
                ScholarshipApplication.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      for (final app in applications) {
        if (app.scholarshipTitle == widget.title) {
          existing = app;
          break;
        }
      }
    }

    final draft = widget.initialDraft ?? existing;
    if (draft != null) {
      _emailController.text = draft.email;
      _statementController.text = draft.statement;
      _attachments.addAll(draft.attachments);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );
      if (result == null) return;
      final newFiles = result.files
          .map(
            (file) => ScholarshipAttachment(
              name: file.name,
              path: file.path,
              size: file.size,
            ),
          )
          .where(
            (file) => !_attachments.any(
              (existing) => existing.path == file.path && file.path != null,
            ),
          )
          .toList();
      if (newFiles.isEmpty) return;
      setState(() {
        _attachments.addAll(newFiles);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to attach documents.')),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final savedAt = DateTime.now().toIso8601String();
    final application = ScholarshipApplication(
      scholarshipTitle: widget.title,
      provider: widget.provider,
      description: widget.description,
      amount: widget.amount,
      currency: widget.currency,
      email: _emailController.text.trim(),
      statement: _statementController.text.trim(),
      attachments: List<ScholarshipAttachment>.from(_attachments),
      savedAt: savedAt,
    );

    final savedJson = _prefs.getString('scholarship_applications');
    final applications = savedJson != null
        ? (jsonDecode(savedJson) as List<dynamic>)
              .map(
                (item) => ScholarshipApplication.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .where((app) => app.scholarshipTitle != widget.title)
              .toList()
        : <ScholarshipApplication>[];
    applications.add(application);

    await _prefs.setString(
      'scholarship_applications',
      jsonEncode(applications.map((app) => app.toJson()).toList()),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application saved locally in the app.')),
      );
    }
  }

  IconData _iconForFile(String name) {
    final extension = name.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.notes;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship Application'),
        backgroundColor: widget.brandColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.currency}${widget.amount.toStringAsFixed(0)} • ${widget.provider}',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.brandColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.82),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address.';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Personal statement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _statementController,
                          minLines: 4,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            hintText:
                                'Describe why you are applying and why you qualify.',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please add a short statement.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Upload documents',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            FilledButton.icon(
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Add files'),
                              onPressed: _pickFiles,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_attachments.isEmpty)
                          Text(
                            'Attach your transcripts, recommendation letters, or other proof documents here.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          )
                        else
                          Column(
                            children: _attachments.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(
                                    _iconForFile(file.name),
                                    color: widget.brandColor,
                                  ),
                                  title: Text(file.name),
                                  subtitle: file.size != null
                                      ? Text(
                                          '${(file.size! / 1024).toStringAsFixed(1)} KB',
                                        )
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeAttachment(index),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 26),
                        Text(
                          'Your application is saved locally in the app. It will not be sent by email automatically.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: _isSaving ? null : _saveApplication,
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.brandColor,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Application',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
