import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'onboarding_budget_page.dart';
import 'onboarding_profile_country.dart';
import 'startup_page.dart';

class OnboardingProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String? phonePrefix;
  final String? phoneNumber;

  const OnboardingProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    this.phonePrefix,
    this.phoneNumber,
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
  String _loadError = '';
  bool _isLoading = true;

  ProfileCountryResult? _countryResult;
  bool _countryLoading = true;
  String? _countryError;

  List<ListInstitutionsInstitutions> _allInstitutions = [];
  List<ListCoursesCourses> _allCourses = [];
  List<String> _institutionNames = [];
  List<String> _courseNames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _detectCountry();
  }

  Future<void> _detectCountry() async {
    if (mounted) {
      setState(() {
        _countryLoading = true;
        _countryError = null;
      });
    }

    try {
      final result = await getCountryFromLocation();
      if (!mounted) return;
      setState(() {
        _countryResult = result;
        _countryLoading = false;
        _countryError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _countryLoading = false;
        _countryResult = null;
        _countryError = _messageForCountryError(e);
      });
    }
  }

  String _messageForCountryError(Object e) {
    if (e is StateError) return e.message;
    if (e is UnsupportedError) return e.message ?? 'Not supported.';
    return 'Could not detect country.';
  }

  Widget _getCountryFlag(String iso3166Alpha2) {
    final cc = CountryCode.tryFromCountryCode(iso3166Alpha2);
    final path = cc?.flagUri;
    if (path == null) {
      return const Icon(Icons.flag_outlined, size: 22);
    }
    return Image.asset(
      path,
      package: 'country_code_picker',
      width: 28,
      fit: BoxFit.contain,
    );
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = '';
      });
    }
    try {
      final connector = ExampleConnector.instance;

      final institutionsResult = await connector.listInstitutions().execute();
      final coursesResult = await connector.listCourses().execute();

      setState(() {
        _allInstitutions = institutionsResult.data.institutions;
        _institutionNames = _allInstitutions.map((i) => i.name).toList();
        _institutionNames.removeWhere((name) => name == 'Other');
        _institutionNames.add('Other');

        _allCourses = coursesResult.data.courses;
        _courseNames = _allCourses.map((c) => c.name).toList();
        _courseNames.removeWhere((name) => name == 'Other');
        _courseNames.add('Other');

        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _loadError = 'Failed to load options. Please check your connection.';
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
    final otherSchoolText = _otherSchoolController.text.trim();
    final otherCourseText = _otherCourseController.text.trim();
    final selectedInstitution = _selectedInstitution;
    final selectedCourse = _selectedCourse;

    if (_countryLoading) {
      setState(() => _error = 'Please wait for location.');
      return;
    }

    if (selectedInstitution == null) {
      setState(() => _error = 'Please select an institution.');
      return;
    }
    if (selectedInstitution == 'Other' && otherSchoolText.isEmpty) {
      setState(() => _error = 'Please specify your institution.');
      return;
    }
    if (selectedCourse == null) {
      setState(() => _error = 'Please select your course of study.');
      return;
    }
    if (selectedCourse == 'Other' && otherCourseText.isEmpty) {
      setState(() => _error = 'Please specify your course of study.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingBudgetPage(
          institutionId: selectedInstitution == 'Other'
              ? null
              : _selectedInstitutionId,
          courseId: selectedCourse == 'Other' ? null : _selectedCourseId,
          otherSchool: selectedInstitution == 'Other' ? otherSchoolText : null,
          otherCourse: selectedCourse == 'Other' ? otherCourseText : null,
          firstName: widget.firstName,
          lastName: widget.lastName,
          countryIsoCode: _countryResult?.isoCountryCode,
          countryDisplayName: _countryResult?.displayName,
          phonePrefix: widget.phonePrefix,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
  }

  Future<void> _confirmCancelRegistration() async {
    if (await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Cancel setup?'),
                content: Text(
                  'Your registration will be canceled.',
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        autofocus: true,
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF3e7f3f),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('No'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(
                            dialogContext,
                          ).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
                        ),
                        child: const Text('Yes, cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ) !=
            true ||
        !mounted) {
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
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
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(hint),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Help us personalise your experience.',
                  style: TextStyle(
                    fontSize: 18,
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
                ] else if (_loadError.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(8),
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
                            _loadError,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontSize: 16,
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
                  if (_error.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEC),
                        borderRadius: BorderRadius.circular(8),
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
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'COUNTRY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  if (_countryLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF3e7f3f),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Detecting country…',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_countryError != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1.0),
                                child: Icon(
                                  Icons.location_off_outlined,
                                  color: Color(0xFF8B0000),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _countryError!,
                                  style: const TextStyle(
                                    color: Color(0xFF8B0000),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _detectCountry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    )
                  else if (_countryResult != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey(
                              '${_countryResult!.isoCountryCode}-'
                              '${_countryResult!.displayName}',
                            ),
                            readOnly: true,
                            initialValue:
                                '${_countryResult!.displayName} (${_countryResult!.isoCountryCode})',
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 1,
                                  child: _getCountryFlag(
                                    _countryResult!.isoCountryCode,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _detectCountry,
                          tooltip: 'Refresh location',
                          icon: const Icon(Icons.refresh),
                          color: const Color(0xFF3e7f3f),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'INSTITUTION',
                      style: TextStyle(
                        fontSize: 16,
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
                          borderRadius: BorderRadius.circular(8),
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
                        fontSize: 16,
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
                          borderRadius: BorderRadius.circular(8),
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
                      onPressed: _countryLoading ? null : _onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3e7f3f),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
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
