import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'onboarding_budget_page.dart';
import 'startup_page.dart';

class OnboardingProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;

  const OnboardingProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
  });
  @override
  State<OnboardingProfilePage> createState() => _OnboardingProfilePageState();
}

class _OnboardingProfilePageState extends State<OnboardingProfilePage> {
  String? _selectedInstitution;
  String? _selectedCourse;
  String? _selectedInstitutionId;
  String? _selectedCourseId;
  final TextEditingController _otherSchoolController = TextEditingController();
  final TextEditingController _otherCourseController = TextEditingController();
  String _error = '';
  bool _isLoading = true;

  List<ListInstitutionsInstitutions> _allInstitutions = [];
  List<ListCoursesCourses> _allCourses = [];
  List<String> _institutionNames = [];
  List<String> _courseNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final connector = ExampleConnector.instance;

      final institutionsResult = await connector.listInstitutions().execute();
      final coursesResult = await connector.listCourses().execute();

      setState(() {
        _allInstitutions = institutionsResult.data.institutions;
        _institutionNames = _allInstitutions.map((i) => i.name).toList();
        if (!_institutionNames.contains('Other')) {
          _institutionNames.add('Other');
        }

        _allCourses = coursesResult.data.courses;
        _courseNames = _allCourses.map((c) => c.name).toList();
        if (!_courseNames.contains('Other')) {
          _courseNames.add('Other');
        }

        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load options. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _otherSchoolController.dispose();
    _otherCourseController.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() => _error = '');

    if (_selectedInstitution == null) {
      setState(() => _error = 'Please select an institution.');
      return;
    }
    if (_selectedInstitution == 'Other' &&
        _otherSchoolController.text.trim().isEmpty) {
      setState(() => _error = 'Please specify your institution.');
      return;
    }
    if (_selectedCourse == null) {
      setState(() => _error = 'Please select your course of study.');
      return;
    }
    if (_selectedCourse == 'Other' &&
        _otherCourseController.text.trim().isEmpty) {
      setState(() => _error = 'Please specify your course of study.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingBudgetPage(
          institutionId: _selectedInstitutionId,
          courseId: _selectedCourseId,
          otherSchool: _selectedInstitution == 'Other'
              ? _otherSchoolController.text.trim()
              : null,
          otherCourse: _selectedCourse == 'Other'
              ? _otherCourseController.text.trim()
              : null,
          firstName: widget.firstName,
          lastName: widget.lastName,
        ),
      ),
    );
  }

  Future<void> _confirmCancelRegistration() async {
    if (await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel setup?'),
                content: const Text('Your registration will be canceled.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes, cancel'),
                  ),
                ],
              ),
            ) !=
            true ||
        !mounted) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const StartupPage()));
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth,
          menuHeight: 200,
          label: Text(hint),
          initialSelection: value,
          enableFilter: true,
          requestFocusOnTap: true,
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).scaffoldBackgroundColor,
            ),
            elevation: const WidgetStatePropertyAll(8),
            surfaceTintColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          dropdownMenuEntries: items.map((String item) {
            return DropdownMenuEntry<String>(value: item, label: item);
          }).toList(),
          onSelected: onChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF3e7f3f),
                        size: 18,
                      ),
                      onPressed: _confirmCancelRegistration,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3e7f3f),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 48.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'Your profile details',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Help us personalise your experience.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),

                if (_isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF3e7f3f),
                      ),
                    ),
                  ),
                ] else if (_error.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFF8B0000),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ] else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'INSTITUTION',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildDropdown(
                    hint: 'Select your institution',
                    value: _selectedInstitution,
                    items: _institutionNames,
                    onChanged: (val) {
                      setState(() {
                        _selectedInstitution = val;
                        _selectedInstitutionId = _allInstitutions
                            .where((i) => i.name == val)
                            .firstOrNull
                            ?.id;
                      });
                    },
                  ),

                  if (_selectedInstitution == 'Other') ...[
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _otherSchoolController,
                      decoration: InputDecoration(
                        hintText: 'Enter institution name',
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'COURSE OF STUDY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildDropdown(
                    hint: 'Select your course',
                    value: _selectedCourse,
                    items: _courseNames,
                    onChanged: (val) {
                      setState(() {
                        _selectedCourse = val;
                        _selectedCourseId = _allCourses
                            .where((c) => c.name == val)
                            .firstOrNull
                            ?.id;
                      });
                    },
                  ),

                  if (_selectedCourse == 'Other') ...[
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _otherCourseController,
                      decoration: InputDecoration(
                        hintText: 'Enter your course name',
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32.0),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3e7f3f),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
