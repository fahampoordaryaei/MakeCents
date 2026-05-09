import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/helper/scholarship_helper.dart';
import 'package:makecents/helper/ui_helper.dart';

import 'package:makecents/widget/busy_button.dart';

class ScholarshipApplicationPage extends StatefulWidget {
  final String? scholarshipId;
  final String title;
  final String provider;
  final double amount;
  final String currency;
  final String description;
  final Color brandColor;
  final ScholarshipApplication? initialDraft;
  final bool readOnly;

  const ScholarshipApplicationPage({
    super.key,
    this.scholarshipId,
    required this.title,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.description,
    required this.brandColor,
    this.initialDraft,
    this.readOnly = false,
  });

  @override
  State<ScholarshipApplicationPage> createState() =>
      _ScholarshipApplicationPageState();
}

class ScholarshipAttachment {
  final String name;
  final String? path;
  final int? size;

  final String? storagePath;

  ScholarshipAttachment({
    required this.name,
    this.path,
    this.size,
    this.storagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      if (storagePath != null) 'storagePath': storagePath,
    };
  }

  factory ScholarshipAttachment.fromJson(Map<String, dynamic> json) {
    return ScholarshipAttachment(
      name: json['name'] as String,
      path: json['path'] as String?,
      size: json['size'] as int?,
      storagePath: json['storagePath'] as String?,
    );
  }
}

class ScholarshipApplication {
  final String? scholarshipId;
  final String scholarshipTitle;
  final String provider;
  final String description;
  final double amount;
  final String currency;
  final String email;
  final String statement;
  final List<ScholarshipAttachment> attachments;
  final String savedAt;
  final int? brandColor;

  ScholarshipApplication({
    this.scholarshipId,
    required this.scholarshipTitle,
    required this.provider,
    required this.description,
    required this.amount,
    required this.currency,
    required this.email,
    required this.statement,
    required this.attachments,
    required this.savedAt,
    this.brandColor,
  });

  Map<String, dynamic> toJson() {
    return {
      if (scholarshipId != null) 'scholarshipId': scholarshipId,
      'scholarshipTitle': scholarshipTitle,
      'provider': provider,
      'description': description,
      'amount': amount,
      'currency': currency,
      'email': email,
      'statement': statement,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'savedAt': savedAt,
      if (brandColor != null) 'brandColor': brandColor,
    };
  }

  factory ScholarshipApplication.fromJson(Map<String, dynamic> json) {
    return ScholarshipApplication(
      scholarshipId: json['scholarshipId'] as String?,
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
      brandColor: (json['brandColor'] as num?)?.toInt(),
    );
  }
}

class _ScholarshipApplicationPageState
    extends State<ScholarshipApplicationPage> {
  static const int _statementMaxChars = 2000;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _statementController = TextEditingController();
  final List<ScholarshipAttachment> _attachments = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSubmitting = false;
  String? _attachmentError;
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

  bool _isPhoneUser() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return false;
    return u.providerData.any((p) => p.providerId == 'phone');
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
    final phoneUser = _isPhoneUser();
    if (draft != null) {
      var statement = draft.statement;
      if (statement.length > _statementMaxChars) {
        statement = statement.substring(0, _statementMaxChars);
      }
      _statementController.text = statement;
      _attachments.addAll(draft.attachments);
    }
    if (phoneUser) {
      if (draft != null) {
        _emailController.text = draft.email;
      }
    } else {
      final acct = FirebaseAuth.instance.currentUser?.email?.trim();
      _emailController.text = (acct != null && acct.isNotEmpty)
          ? acct
          : (draft?.email ?? '').trim();
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickFiles() async {
    if (widget.readOnly) return;
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
      if (!mounted) return;
      setState(() {
        _attachments.addAll(newFiles);
        _attachmentError = null;
      });
    } catch (e) {
      debugPrint('scholarship_application_page._pickFiles failed: $e');
      if (!mounted) return;
      await popupAlert(
        context,
        message: 'Unable to attach documents.',
        level: AppAlertLevel.error,
      );
    }
  }

  void _removeAttachment(int index) {
    if (widget.readOnly) return;
    setState(() {
      _attachments.removeAt(index);
      if (_attachments.isNotEmpty) _attachmentError = null;
    });
  }

  Future<void> _openAttachment(ScholarshipAttachment file) async {
    late final Uri uri;
    if (file.storagePath != null) {
      try {
        uri = Uri.parse(
          await FirebaseStorage.instance
              .ref(file.storagePath!)
              .getDownloadURL(),
        );
      } catch (e) {
        debugPrint('scholarship_application_page._openAttachment failed: $e');
        if (!mounted) return;
        await popupAlert(
          context,
          message: 'The document could not be opened.',
          level: AppAlertLevel.error,
        );
        return;
      }
    } else if (file.path != null) {
      uri = Uri.file(file.path!, windows: Platform.isWindows);
    } else {
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      await popupAlert(
        context,
        message: 'The document could not be opened.',
        level: AppAlertLevel.error,
      );
    }
  }

  Future<void> _submitApplication() async {
    if (widget.readOnly) return;
    if (!_formKey.currentState!.validate()) return;
    if (_attachments.isEmpty) {
      setState(() => _attachmentError = 'Please upload at least one document.');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    final scholarshipId = widget.scholarshipId;
    if (user == null || scholarshipId == null) return;

    setState(() {
      _attachmentError = null;
      _isSubmitting = true;
    });
    try {
      final connector = ExampleConnector.instance;
      final dup = await connector
          .scholarshipApplicationExists(
            userId: user.uid,
            scholarshipId: scholarshipId,
          )
          .execute();
      if (dup.data.scholarshipApplications.isNotEmpty) {
        if (!mounted) return;
        await popupAlert(
          context,
          message: 'You already submitted an application for this scholarship.',
          level: AppAlertLevel.warning,
        );
        return;
      }
      final uploaded = <UploadResult>[];
      for (final attachment in _attachments) {
        final result = await uploadAttachment(
          File(attachment.path!),
          displayName: attachment.name,
        );
        uploaded.add(result);
      }
      final applicationId = const Uuid().v4();
      await connector
          .createScholarshipApplication(
            id: applicationId,
            userId: user.uid,
            scholarshipId: scholarshipId,
          )
          .message(_statementController.text.trim())
          .execute();

      for (final file in uploaded) {
        await connector
            .createScholarshipAttachment(
              id: const Uuid().v4(),
              scholarshipApplicationId: applicationId,
              filename: file.filename,
              path: file.path,
            )
            .execute();
      }
      try {
        final notify = _emailController.text.trim();
        await FirebaseFunctions.instanceFor(region: 'europe-west1')
            .httpsCallable('sendScholarshipApplicationEmail')
            .call(<String, dynamic>{
              'applicationId': applicationId,
              if (notify.isNotEmpty) 'notificationEmail': notify,
            });
      } catch (e) {
        debugPrint(
          'scholarship_application_page.sendScholarshipApplicationEmail failed: $e',
        );
      }
      final savedJson = _prefs.getString('scholarship_applications');
      if (savedJson != null) {
        final remaining = (jsonDecode(savedJson) as List<dynamic>)
            .map(
              (item) =>
                  ScholarshipApplication.fromJson(item as Map<String, dynamic>),
            )
            .where((app) => app.scholarshipTitle != widget.title)
            .toList();
        await _prefs.setString(
          'scholarship_applications',
          jsonEncode(remaining.map((app) => app.toJson()).toList()),
        );
      }
      if (!mounted) return;
      await popupAlert(
        context,
        message: 'Application submitted.',
        level: AppAlertLevel.success,
      );
    } catch (e) {
      if (!mounted) return;
      await popupAlert(
        context,
        message: 'Submission failed. Check your connection and try again.',
        level: AppAlertLevel.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _saveApplication() async {
    if (widget.readOnly) return;
    if (!_isPhoneUser()) {
      final acct = FirebaseAuth.instance.currentUser?.email?.trim() ?? '';
      if (acct.isNotEmpty) _emailController.text = acct;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final savedAt = DateTime.now().toIso8601String();
    final application = ScholarshipApplication(
      scholarshipId: widget.scholarshipId,
      scholarshipTitle: widget.title,
      provider: widget.provider,
      description: widget.description,
      amount: widget.amount,
      currency: widget.currency,
      email: _emailController.text.trim(),
      statement: _statementController.text.trim(),
      attachments: List<ScholarshipAttachment>.from(_attachments),
      savedAt: savedAt,
      brandColor: widget.brandColor.toARGB32(),
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
      await popupAlert(
        context,
        message: 'Application saved.',
        level: AppAlertLevel.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final busy = _isSaving || _isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.readOnly ? 'Submitted application' : 'Scholarship Application',
        ),
        backgroundColor: widget.brandColor,
        foregroundColor: scheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.currency}${widget.amount.toStringAsFixed(0)} • ${widget.provider}',
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.brandColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          readOnly: widget.readOnly || !_isPhoneUser() || busy,
                          decoration: InputDecoration(
                            labelText: 'Email address',
                            border: OutlineInputBorder(),
                            filled: !_isPhoneUser(),
                            fillColor: !_isPhoneUser()
                                ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5)
                                : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (widget.readOnly) return null;
                            if (!_isPhoneUser()) return null;
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
                          readOnly: widget.readOnly || busy,
                          minLines: 4,
                          maxLines: 8,
                          maxLength: widget.readOnly
                              ? null
                              : _statementMaxChars,
                          decoration: const InputDecoration(
                            hintText:
                                'Describe why you are applying and why you qualify.',
                            border: OutlineInputBorder(),
                            counterStyle: TextStyle(fontSize: 16),
                          ),
                          validator: (value) {
                            if (widget.readOnly) return null;
                            if (value == null || value.trim().isEmpty) {
                              return 'Please add a short statement.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.readOnly
                                    ? 'Submitted documents'
                                    : 'Upload documents',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (!widget.readOnly)
                              FilledButton.icon(
                                icon: const Icon(Icons.attach_file),
                                label: const Text('Add files'),
                                onPressed: busy ? null : _pickFiles,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_attachments.isEmpty)
                          Text(
                            widget.readOnly
                                ? ''
                                : 'Attach your transcripts, recommendation letters, or other proof documents here.',
                            style: TextStyle(fontSize: 16),
                          )
                        else
                          Column(
                            children: _attachments.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              final subtitleParts = <String>[];
                              if (file.storagePath != null) {
                                subtitleParts.add('Uploaded');
                              }
                              if (file.size != null) {
                                subtitleParts.add(
                                  '${(file.size! / 1024).toStringAsFixed(1)} KB',
                                );
                              }
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(
                                    file.storagePath != null
                                        ? Icons.cloud_done_outlined
                                        : Icons.attach_file,
                                    color: widget.brandColor,
                                  ),
                                  title: Text(file.name),
                                  subtitle: subtitleParts.isEmpty
                                      ? null
                                      : Text(subtitleParts.join(' • ')),
                                  trailing: widget.readOnly
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: busy
                                              ? null
                                              : () => _removeAttachment(index),
                                        ),
                                  onTap: busy
                                      ? null
                                      : () => _openAttachment(file),
                                ),
                              );
                            }).toList(),
                          ),
                        if (_attachmentError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _attachmentError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (!widget.readOnly) ...[
                          const SizedBox(height: 26),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.brandColor,
                              foregroundColor: scheme.onPrimary,
                              disabledBackgroundColor:
                                  scheme.surfaceContainerHighest,
                              disabledForegroundColor: scheme.onSurface
                                  .withValues(alpha: 0.38),
                              minimumSize: const Size.fromHeight(52),
                            ),
                            onPressed: busy ? null : _submitApplication,
                            child: busyButton(
                              context: context,
                              busy: _isSubmitting,
                              label: 'Submit Application',
                              size: 20,
                              labelStyle: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: busy ? null : _saveApplication,
                              style: TextButton.styleFrom(
                                foregroundColor: scheme.primary,
                              ),
                              child: const Text(
                                'Save Application',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
