import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'functions.dart';
import 'main.dart';
import 'mfa_provider.dart';

class OnboardingMfaPage extends StatefulWidget {
  const OnboardingMfaPage({super.key});

  @override
  State<OnboardingMfaPage> createState() => _OnboardingMfaPageState();
}

class _OnboardingMfaPageState extends State<OnboardingMfaPage> {
  bool _busy = false;
  String _error = '';
  TotpSecret? _totpSecret;
  final _codeController = TextEditingController();
  bool _offerResend = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  User? get _current => FirebaseAuth.instance.currentUser;

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _resetIntro() {
    setState(() {
      _totpSecret = null;
      _codeController.clear();
      _error = '';
      _offerResend = false;
    });
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _busy = true);
    try {
      await sendUserEmailVerification(_current!);
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Check your inbox.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is FirebaseAuthException
            ? (e.message ?? e.code)
            : e.toString();
      });
    }
  }

  void _unverifiedEmail() {
    setState(() {
      _busy = false;
      _offerResend = true;
      _error = 'Verify your email and try again.';
    });
  }

  Future<void> _startEnrollment() async {
    final u = _current!;

    setState(() {
      _busy = true;
      _error = '';
      _offerResend = false;
    });

    try {
      final email = u.email;
      if (email != null && email.isNotEmpty) {
        await u.reload();
        if (!mounted) return;
        if (!u.emailVerified) {
          _unverifiedEmail();
          return;
        }
      }

      final secret = await startTotpSession();
      if (!mounted) return;
      setState(() {
        _totpSecret = secret;
        _busy = false;
        _offerResend = false;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'ERROR_UNVERIFIED_EMAIL' || e.code == 'unverified-email') {
        _unverifiedEmail();
      } else {
        setState(() {
          _busy = false;
          _offerResend = false;
          _error = e.message ?? e.code;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offerResend = false;
        _error = e is FirebaseAuthException
            ? (e.message ?? e.code)
            : e.toString();
      });
    }
  }

  Future<void> _verifyAndEnroll() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Enter the 6-digit code from your app.');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
      _offerResend = false;
    });
    try {
      await completeTotp(
        totpSecret: _totpSecret!,
        oneTimePassword: code,
        displayName: 'Authenticator',
      );
      if (!mounted) return;
      _goHome(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offerResend = false;
        _error = e is FirebaseAuthException
            ? (e.message ?? e.code)
            : e.toString();
      });
    }
  }

  Future<void> _copySecretToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _totpSecret!.secretKey));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secret copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final muted = onSurface.withValues(alpha: 0.75);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
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
                    margin: const EdgeInsets.only(bottom: 12),
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
                      onPressed: _busy
                          ? null
                          : () {
                              if (_totpSecret != null) {
                                _resetIntro();
                              } else if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                    ),
                  ),
                ),
                if (_totpSecret == null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3e7f3f),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Enable MFA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protects your account by adding an additional layer of security.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.4, color: muted),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _startEnrollment,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3e7f3f),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enable MFA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Set up your authenticator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan the QR code with your app, or paste the secret key into the authenticator app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: muted),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<Widget>(
                    future: buildTotpEnrollmentQrView(
                      secret: _totpSecret!,
                      accountName: _current?.email ?? _current?.uid,
                      issuer: 'MakeCents',
                      size: 200,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Text(
                          'QR error: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: Color(0xFF3e7f3f),
                          ),
                        );
                      }
                      return snap.data!;
                    },
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _totpSecret!.secretKey,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _copySecretToClipboard,
                    child: const Text(
                      'Copy secret',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: '6-digit code from your app',
                      counterText: '',
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _verifyAndEnroll,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3e7f3f),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF8B0000),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_offerResend) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _sendVerificationEmail,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3e7f3f),
                        side: const BorderSide(color: Color(0xFF3e7f3f)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Resend verification email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_totpSecret == null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy ? null : () => _goHome(context),
                    style: TextButton.styleFrom(foregroundColor: muted),
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
