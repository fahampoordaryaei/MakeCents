import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import 'dataconnect_generated/generated.dart';
import 'onboarding_profile_country.dart';
import 'user_provider.dart';

class OnboardingProfileSelection {
  const OnboardingProfileSelection({
    required this.institutionId,
    required this.courseId,
    required this.otherInstitution,
    required this.otherCourse,
    this.countryIsoCode,
    this.countryDisplayName,
  });

  final String? institutionId;
  final String? courseId;
  final String? otherInstitution;
  final String? otherCourse;
  final String? countryIsoCode;
  final String? countryDisplayName;
}

class OnboardingProfileForm extends StatefulWidget {
  const OnboardingProfileForm({
    super.key,
    this.initialProfile,
    this.onUpdated,
  });

  final UserProfile? initialProfile;
  final VoidCallback? onUpdated;

  @override
  OnboardingProfileFormState createState() => OnboardingProfileFormState();
}

class OnboardingProfileFormState extends State<OnboardingProfileForm> {
  String? _selectedInstitution;
  String? _selectedCourse;
  String? _selectedInstitutionId;
  String? _selectedCourseId;
  final TextEditingController _otherInstitutionController =
      TextEditingController();
  final TextEditingController _otherCourseController = TextEditingController();
  String _validationError = '';
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

  @override
  void dispose() {
    _otherInstitutionController.dispose();
    _otherCourseController.dispose();
    super.dispose();
  }

  bool get canSubmit => !_isLoading && _loadError.isEmpty && !_countryLoading;

  String? validate() {
    _validationError = '';

    if (_countryLoading) {
      _validationError = 'Please wait for location.';
      setState(() {});
      return _validationError;
    }

    final otherInstitutionText = _otherInstitutionController.text.trim();
    final otherCourseText = _otherCourseController.text.trim();
    final selectedInstitution = _selectedInstitution;
    final selectedCourse = _selectedCourse;

    if (selectedInstitution == null) {
      _validationError = 'Please select an institution.';
      setState(() {});
      return _validationError;
    }
    if (selectedInstitution == 'Other' && otherInstitutionText.isEmpty) {
      _validationError = 'Please specify your institution.';
      setState(() {});
      return _validationError;
    }
    if (selectedCourse == null) {
      _validationError = 'Please select your course of study.';
      setState(() {});
      return _validationError;
    }
    if (selectedCourse == 'Other' && otherCourseText.isEmpty) {
      _validationError = 'Please specify your course of study.';
      setState(() {});
      return _validationError;
    }

    setState(() {});
    return null;
  }

  OnboardingProfileSelection buildSelection() {
    final otherInstitutionText = _otherInstitutionController.text.trim();
    final otherCourseText = _otherCourseController.text.trim();
    final selectedInstitution = _selectedInstitution!;
    final selectedCourse = _selectedCourse!;
    return OnboardingProfileSelection(
      institutionId: selectedInstitution == 'Other'
          ? null
          : _selectedInstitutionId,
      courseId: selectedCourse == 'Other' ? null : _selectedCourseId,
      otherInstitution: selectedInstitution == 'Other'
          ? otherInstitutionText
          : null,
      otherCourse: selectedCourse == 'Other' ? otherCourseText : null,
      countryIsoCode: _countryResult?.isoCountryCode,
      countryDisplayName: _countryResult?.displayName,
    );
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
      widget.onUpdated?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _countryLoading = false;
        _countryResult = null;
        _countryError = _messageForCountryError(e);
      });
      widget.onUpdated?.call();
    }
  }

  String _messageForCountryError(Object e) {
    if (e is StateError) return e.message;
    if (e is UnsupportedError) return e.message ?? 'Not supported.';
    return 'Could not detect country.';
  }

  Widget _countryFlag(String iso3166Alpha2) {
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

  void _applyProfilePrefill(UserProfile p) {
    final otherS = p.otherInstitution?.trim() ?? '';
    if (otherS.isNotEmpty) {
      _selectedInstitution = 'Other';
      _selectedInstitutionId = null;
      _otherInstitutionController.text = otherS;
    } else if ((p.institution ?? '').trim().isNotEmpty) {
      final match = _allInstitutions
          .where((i) => i.name == p.institution)
          .firstOrNull;
      if (match != null) {
        _selectedInstitution = match.name;
        _selectedInstitutionId = match.id;
      }
    }

    final otherC = p.otherCourse?.trim() ?? '';
    if (otherC.isNotEmpty) {
      _selectedCourse = 'Other';
      _selectedCourseId = null;
      _otherCourseController.text = otherC;
    } else if ((p.courseId ?? '').trim().isNotEmpty) {
      final matchC = _allCourses.where((c) => c.id == p.courseId).firstOrNull;
      if (matchC != null) {
        _selectedCourse = matchC.name;
        _selectedCourseId = matchC.id;
      }
    } else if ((p.course ?? '').trim().isNotEmpty) {
      final matchC = _allCourses.where((c) => c.name == p.course).firstOrNull;
      if (matchC != null) {
        _selectedCourse = matchC.name;
        _selectedCourseId = matchC.id;
      }
    }
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

      if (!mounted) return;
      setState(() {
        _allInstitutions = institutionsResult.data.institutions;
        _institutionNames = _allInstitutions.map((i) => i.name).toList();
        _institutionNames.removeWhere((name) => name == 'Other');
        _institutionNames.add('Other');

        _allCourses = coursesResult.data.courses;
        _courseNames = _allCourses.map((c) => c.name).toList();
        _courseNames.removeWhere((name) => name == 'Other');
        _courseNames.add('Other');

        final initial = widget.initialProfile;
        if (initial != null) {
          _applyProfilePrefill(initial);
        }
        _isLoading = false;
      });
      widget.onUpdated?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load options. Please check your connection.';
        _isLoading = false;
      });
      widget.onUpdated?.call();
    }
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
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
          vertical: 14,
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
        ),
      );
    }

    if (_loadError.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _loadError,
            style: const TextStyle(color: Color(0xFF8B0000), fontSize: 16),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_validationError.isNotEmpty) ...[
          Text(
            _validationError,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'COUNTRY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_countryLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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
              Text(
                _countryError!,
                style: const TextStyle(color: Color(0xFF8B0000), fontSize: 15),
              ),
              const SizedBox(height: 8),
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
                        child: _countryFlag(_countryResult!.isoCountryCode),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
        const SizedBox(height: 20),
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
        const SizedBox(height: 8),
        _dropdown(
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
          const SizedBox(height: 10),
          TextFormField(
            controller: _otherInstitutionController,
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
                vertical: 14,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
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
        const SizedBox(height: 8),
        _dropdown(
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
          const SizedBox(height: 10),
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
                vertical: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
