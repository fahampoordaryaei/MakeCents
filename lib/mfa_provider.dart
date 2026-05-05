import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'functions.dart';
import 'theme_provider.dart';

Future<TotpSecret> startTotpSession() async {
  final u = FirebaseAuth.instance.currentUser!;
  final session = await u.multiFactor.getSession();
  return TotpMultiFactorGenerator.generateSecret(session);
}

Future<void> completeTotp({
  required TotpSecret totpSecret,
  required String oneTimePassword,
  required String displayName,
}) async {
  final u = FirebaseAuth.instance.currentUser!;
  final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
    totpSecret,
    oneTimePassword.trim(),
  );
  await u.multiFactor.enroll(assertion, displayName: displayName);
}

Future<void> unenrollTotp(User user) async {
  final factors = await user.multiFactor.getEnrolledFactors();
  for (final factor in factors) {
    if (factor.factorId == 'totp') {
      await user.multiFactor.unenroll(multiFactorInfo: factor);
      return;
    }
  }
}

Future<void> reauthenticateUser({
  required User user,
  required String email,
  required String password,
  String totpForSignIn = '',
}) async {
  try {
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
  } on FirebaseAuthMultiFactorException catch (e) {
    final trimmed = totpForSignIn.trim();
    final MultiFactorInfo totp = e.resolver.hints.firstWhere(
      (h) => h.factorId == 'totp',
    );
    final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
      totp.uid,
      trimmed,
    );
    await e.resolver.resolveSignIn(assertion);
  }
}

String _firebaseErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    return e.message ?? e.code;
  }
  return e.toString();
}

Widget buildQrCode(
  String data, {
  double size = 200,
  Color backgroundColor = Colors.white,
  Color foregroundColor = Colors.black,
}) {
  return QrImageView(
    data: data,
    version: QrVersions.auto,
    size: size,
    backgroundColor: backgroundColor,
    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: foregroundColor),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: foregroundColor,
    ),
  );
}

class MfaEnrollmentWidget extends StatefulWidget {
  const MfaEnrollmentWidget({
    super.key,
    required this.onBackWhenNoSecret,
    required this.onEnrolledSuccess,
    this.showSkipForNow = false,
    this.onSkipForNow,
    this.showLeadingBackButton = true,
    this.onClose,
    this.disablePasswordField = false,
  });

  final VoidCallback onBackWhenNoSecret;
  final VoidCallback onEnrolledSuccess;
  final VoidCallback? onSkipForNow;
  final VoidCallback? onClose;

  final bool showSkipForNow;
  final bool showLeadingBackButton;
  // Skip password if still authenticated
  final bool disablePasswordField;

  @override
  State<MfaEnrollmentWidget> createState() => _MfaEnrollmentWidgetState();
}

class _MfaEnrollmentWidgetState extends State<MfaEnrollmentWidget> {
  bool _busy = false;
  String _error = '';
  TotpSecret? _totpSecret;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _offerResend = false;
  bool _attemptedEnableMfa = false;
  bool _attemptedVerifyCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  User? get _current => FirebaseAuth.instance.currentUser;

  void _resetState() {
    setState(() {
      _totpSecret = null;
      _codeController.clear();
      _passwordController.clear();
      _error = '';
      _offerResend = false;
      _attemptedEnableMfa = false;
      _attemptedVerifyCode = false;
    });
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _busy = true);
    try {
      await sendUserEmailVerification(_current!);
      if (!mounted) return;
      setState(() => _busy = false);
      final email = _current!.email?.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('We sent a verification email to $email.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _firebaseErrorMessage(e);
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

  Future<bool> _checkTotpState(User u) async {
    if (u.email?.trim().isNotEmpty ?? false) {
      await u.reload();
      if (!mounted) return false;
      if (!u.emailVerified) {
        _unverifiedEmail();
        return false;
      }
    }

    if (!widget.disablePasswordField) {
      final loginEmail = u.email?.trim() ?? '';
      await reauthenticateUser(
        user: u,
        email: loginEmail,
        password: _passwordController.text,
      );
    }

    final secret = await startTotpSession();
    if (!mounted) return false;
    setState(() {
      _totpSecret = secret;
      _busy = false;
      _offerResend = false;
      _passwordController.clear();
    });
    return true;
  }

  Future<void> _startEnrollment() async {
    final u = _current!;

    if (!widget.disablePasswordField && _passwordController.text.isEmpty) {
      setState(() {
        _attemptedEnableMfa = true;
        _error = '';
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = '';
      _offerResend = false;
      _attemptedEnableMfa = false;
    });

    try {
      final reachedSecret = await _checkTotpState(u);
      if (reachedSecret) return;
      return;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offerResend = false;
        _error = _firebaseErrorMessage(e);
      });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offerResend = false;
        _error = _firebaseErrorMessage(e);
      });
      return;
    }
  }

  Future<void> _verifyEnroll() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() {
        _attemptedVerifyCode = true;
        _error = '';
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
      _offerResend = false;
      _attemptedVerifyCode = false;
    });

    try {
      await completeTotp(
        totpSecret: _totpSecret!,
        oneTimePassword: code,
        displayName: 'Authenticator',
      );
      if (!mounted) return;
      widget.onEnrolledSuccess();
      return;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offerResend = false;
        _error = _firebaseErrorMessage(e);
      });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _offerResend = false;
        _error = _firebaseErrorMessage(e);
      });
      return;
    }
  }

  Future<void> _copySecret() async {
    await Clipboard.setData(ClipboardData(text: _totpSecret!.secretKey));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secret copied to clipboard.')),
    );
  }

  void _onSkip() {
    final fn = widget.onSkipForNow;
    if (fn != null) {
      fn();
    } else {
      widget.onBackWhenNoSecret();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final user = _current;
    String? qrAccountName;
    if (user != null) {
      final mail = user.email?.trim();
      qrAccountName = mail?.isNotEmpty ?? false ? mail : user.uid;
    }
    return Container(
      padding: const EdgeInsets.all(30),
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
          if (widget.showLeadingBackButton)
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
                            _resetState();
                          } else {
                            widget.onBackWhenNoSecret();
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
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enabled: !widget.disablePasswordField && !_busy,
              style: const TextStyle(fontSize: 18),
              onChanged: (_) {
                if (_attemptedEnableMfa) setState(() {});
              },
              decoration: requiredField(
                context,
                label: 'Password',
                hasError:
                    !widget.disablePasswordField &&
                    _attemptedEnableMfa &&
                    _passwordController.text.isEmpty,
              ),
            ),
            const SizedBox(height: 24),
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
              'Scan the QR code or paste the secret key into your authenticator app.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            FutureBuilder<Widget>(
              future: _totpSecret!
                  .generateQrCodeUrl(
                    accountName: qrAccountName,
                    issuer: 'MakeCents',
                  )
                  .then(
                    (uri) => buildQrCode(
                      uri,
                      size: 200,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
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
                    child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
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
            IconButton(
              onPressed: _copySecret,
              tooltip: 'Copy secret',
              icon: const Icon(Icons.content_copy),
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF3e7f3f),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 18),
              onChanged: (_) {
                if (_attemptedVerifyCode) setState(() {});
              },
              decoration: requiredField(
                context,
                label: 'Authenticator code',
                hasError:
                    _attemptedVerifyCode &&
                    _codeController.text.trim().length < 6,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _verifyEnroll,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          if (widget.showSkipForNow && _totpSecret == null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _busy ? null : _onSkip,
              style: TextButton.styleFrom(foregroundColor: onSurface),
              child: const Text(
                'Skip for now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (widget.onClose != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _busy ? null : widget.onClose,
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showMfaAccountDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const _MfaAccountDialog(),
  );
}

class _MfaAccountDialog extends StatefulWidget {
  const _MfaAccountDialog();

  @override
  State<_MfaAccountDialog> createState() => _MfaAccountDialogState();
}

class _MfaAccountDialogState extends State<_MfaAccountDialog> {
  bool _loading = true;
  bool _totpOn = false;
  bool _busy = false;
  String _error = '';

  bool _showDisableForm = false;
  final _disablePasswordCtrl = TextEditingController();
  final _disableTotpCtrl = TextEditingController();
  bool _attemptedDisableConfirm = false;

  @override
  void dispose() {
    _disablePasswordCtrl.dispose();
    _disableTotpCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final u = FirebaseAuth.instance.currentUser!;
    final factors = await u.multiFactor.getEnrolledFactors();
    final on = factors.any((f) => f.factorId == 'totp');
    if (!mounted) return;
    setState(() {
      _totpOn = on;
      _loading = false;
    });
  }

  void _initDisableMfa() {
    setState(() {
      _showDisableForm = true;
      _error = '';
      _attemptedDisableConfirm = false;
      _disablePasswordCtrl.clear();
      _disableTotpCtrl.clear();
    });
  }

  Future<void> _submitDisableMfa() async {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email?.trim();
    final password = _disablePasswordCtrl.text;
    final code = _disableTotpCtrl.text.trim();
    if (password.isEmpty || code.isEmpty) {
      setState(() {
        _error = '';
        _attemptedDisableConfirm = true;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = '';
      _attemptedDisableConfirm = false;
    });

    try {
      await reauthenticateUser(
        user: user,
        email: email ?? '',
        password: password,
        totpForSignIn: code,
      );
      await unenrollTotp(user);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Multi-factor authentication has been disabled.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _attemptedDisableConfirm = false;
        _error = e.message ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _attemptedDisableConfirm = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        'Authenticator (MFA)',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
                  ),
                )
              : _totpOn
              ? _buildEnabledForm(context)
              : MfaEnrollmentWidget(
                  showLeadingBackButton: false,
                  onClose: () => Navigator.of(context).pop(),
                  onBackWhenNoSecret: () => Navigator.of(context).pop(),
                  onEnrolledSuccess: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context).pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Authenticator (MFA) is enabled.'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEnabledForm(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(30),
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
          const SizedBox(height: 24),
          Text(
            'MFA is enabled',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Additional security measure for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.4,
              color: onSurface.withValues(alpha: 0.75),
            ),
          ),
          if (_showDisableForm) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _disablePasswordCtrl,
              obscureText: true,
              enabled: !_busy,
              style: const TextStyle(fontSize: 18),
              onChanged: (_) {
                if (_attemptedDisableConfirm) setState(() {});
              },
              decoration: requiredField(
                context,
                label: 'Password',
                hasError:
                    _attemptedDisableConfirm &&
                    _disablePasswordCtrl.text.isEmpty,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _disableTotpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_busy,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 18),
              onChanged: (_) {
                if (_attemptedDisableConfirm) setState(() {});
              },
              decoration: requiredField(
                context,
                label: 'Authenticator code',
                hasError:
                    _attemptedDisableConfirm &&
                    _disableTotpCtrl.text.trim().isEmpty,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _submitDisableMfa,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDD403D),
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
                        'Disable MFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _initDisableMfa,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDD403D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Disable MFA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
