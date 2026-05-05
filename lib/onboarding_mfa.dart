import 'package:flutter/material.dart';

import 'main.dart';
import 'mfa_provider.dart';

class OnboardingMfaPage extends StatelessWidget {
  const OnboardingMfaPage({super.key});

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: MfaEnrollmentWidget(
              disablePasswordField: true,
              onBackWhenNoSecret: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  _goHome(context);
                }
              },
              onEnrolledSuccess: () => _goHome(context),
              showSkipForNow: true,
              onSkipForNow: () => _goHome(context),
            ),
          ),
        ),
      ),
    );
  }
}
