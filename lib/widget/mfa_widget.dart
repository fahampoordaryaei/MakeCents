import 'package:flutter/material.dart';

import 'package:makecents/main.dart';
import 'package:makecents/provider/mfa_provider.dart';

class MfaWidget extends StatelessWidget {
  const MfaWidget({super.key});

  void _goHome(BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: MfaEnrollmentWidget(
                disablePasswordField: true,
                onBackWhenNoSecret: () {
                  if (!context.mounted) return;
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
      ),
    );
  }
}
