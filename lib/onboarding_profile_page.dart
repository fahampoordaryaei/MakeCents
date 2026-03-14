import 'package:flutter/material.dart';
import 'onboarding_budget_page.dart';
import 'dataconnect_generated/generated.dart';

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
  String? _selectedSchool;
  String? _selectedCourse;
  String? _selectedSchoolId;
  String? _selectedCourseId;
  final TextEditingController _otherSchoolController = TextEditingController();
  final TextEditingController _otherCourseController = TextEditingController();
  String _error = '';
  bool _isLoading = true;

  List<ListSchoolsSchools> _allSchools = [];
  List<ListCoursesCourses> _allCourses = [];
  List<String> _schoolNames = [];
  List<String> _courseNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final connector = ExampleConnector.instance;

      final schoolsResult = await connector.listSchools().execute();
      final coursesResult = await connector.listCourses().execute();

      setState(() {
        _allSchools = schoolsResult.data.schools;
        _schoolNames = _allSchools.map((s) => s.name).toList();
        if (!_schoolNames.contains('Other')) _schoolNames.add('Other');

        _allCourses = coursesResult.data.courses;
        _courseNames = _allCourses.map((c) => c.name).toList();
        if (!_courseNames.contains('Other')) _courseNames.add('Other');

        _isLoading = false;
      });
    } catch (e) {
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

    if (_selectedSchool == null) {
      setState(() => _error = 'Please select a school.');
      return;
    }
    if (_selectedSchool == 'Other' &&
        _otherSchoolController.text.trim().isEmpty) {
      setState(() => _error = 'Please specify your school.');
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
          schoolId: _selectedSchoolId,
          courseId: _selectedCourseId,
          otherSchool: _selectedSchool == 'Other'
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
                        Icons.arrow_back,
                        color: Color(0xFF3e7f3f),
                        size: 18,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
                  'Tell us more',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Help us personalize your tracking experience.',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
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
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ] else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SCHOOL OR UNIVERSITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildDropdown(
                    hint: 'Select your school',
                    value: _selectedSchool,
                    items: _schoolNames,
                    onChanged: (val) {
                      setState(() {
                        _selectedSchool = val;
                        _selectedSchoolId = _allSchools
                            .where((s) => s.name == val)
                            .firstOrNull
                            ?.id;
                      });
                    },
                  ),

                  if (_selectedSchool == 'Other') ...[
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _otherSchoolController,
                      decoration: InputDecoration(
                        hintText: 'Enter school name',
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
                        fontSize: 12,
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
                        'Continue',
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
