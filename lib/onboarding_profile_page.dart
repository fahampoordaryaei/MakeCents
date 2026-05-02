import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'onboarding_profile_form.dart';
import 'onboarding_budget_page.dart';
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
  final GlobalKey<OnboardingProfileFormState> _formKey =
      GlobalKey<OnboardingProfileFormState>();

  void _onContinue() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (form.validate() != null) return;
    final sel = form.buildSelection();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingBudgetPage(
          institutionId: sel.institutionId,
          courseId: sel.courseId,
          otherInstitution: sel.otherInstitution,
          otherCourse: sel.otherCourse,
          firstName: widget.firstName,
          lastName: widget.lastName,
          countryIsoCode: sel.countryIsoCode,
          countryDisplayName: sel.countryDisplayName,
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
      await FirebaseAuth.instance.currentUser!.delete();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const StartupPage()));
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

                OnboardingProfileForm(
                  key: _formKey,
                  onUpdated: () {
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _formKey.currentState?.canSubmit == true
                        ? _onContinue
                        : null,
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
            ),
          ),
        ),
      ),
    );
  }
}
