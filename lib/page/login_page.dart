import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/main.dart';
import 'package:makecents/page/forgot_password_page.dart';
import 'package:makecents/page/onboarding_profile_page.dart';
import 'package:makecents/page/register_page.dart';
import 'package:makecents/page/startup_page.dart';
import 'package:makecents/provider/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identityCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _emailMfaCodeCtrl = TextEditingController();

  String _error = '';

  bool _obscure = true;
  bool _isLoading = false;
  bool _usePhoneLogin = false;
  bool _codeSent = false;

  String? _verificationId;
  String _countryCode = '+356';

  bool _emailMfaPending = false;
  MultiFactorResolver? _emailMfaResolver;
  String? _pendingDbUserId;

  bool _submitAttempted = false;

  @override
  void dispose() {
    _identityCtrl.dispose();
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
    _emailMfaCodeCtrl.dispose();
    super.dispose();
  }

  void _resetEmailMfaFlow() {
    _pendingDbUserId = null;
    _emailMfaPending = false;
    _emailMfaResolver = null;
    _emailMfaCodeCtrl.clear();
  }

  String? _totpEnrollmentId(MultiFactorResolver r) {
    final i = r.hints.indexWhere((h) => h.factorId == 'totp');
    return i < 0 ? null : r.hints[i].uid;
  }

  void _setLoginChannel(bool phone) {
    setState(() {
      _usePhoneLogin = phone;
      _codeSent = false;
      _verificationId = null;
      _codeCtrl.clear();
      _identityCtrl.clear();
      _error = '';
      _submitAttempted = false;
      _resetEmailMfaFlow();
    });
  }

  Future<void> _signIn() async {
    final identity = _identityCtrl.text.trim();
    if (identity.isEmpty) {
      setState(() {
        _submitAttempted = true;
        _error = '';
      });
      return;
    }

    if (_usePhoneLogin) {
      if (_codeSent) {
        await _verifyPhoneCode();
      } else {
        await _sendPhoneCode(identity);
      }
      return;
    }

    final email = identity;
    if (_emailMfaPending) {
      await _verifyEmailMfa();
      return;
    }

    final pass = _passwordCtrl.text;
    if (pass.isEmpty) {
      setState(() {
        _submitAttempted = true;
        _error = '';
      });
      return;
    }

    setState(() {
      _error = '';
      _submitAttempted = false;
      _isLoading = true;
    });

    try {
      final connector = ExampleConnector.instance;
      String? dbUserId;
      final statusResult = await connector
          .getLoginStatus(email: email)
          .execute();
      if (statusResult.data.users.isNotEmpty) {
        final user = statusResult.data.users.first;
        dbUserId = user.userId;
        final lockedUntil = user.lockedUntil?.toDateTime();

        if (lockedUntil != null && DateTime.now().isBefore(lockedUntil)) {
          final remaining =
              lockedUntil.difference(DateTime.now()).inMinutes + 1;
          if (!mounted) return;
          setState(() {
            _error =
                'Account locked. Try again in $remaining minute${remaining == 1 ? '' : 's'}.';
            _isLoading = false;
          });
          return;
        }
      }

      _pendingDbUserId = dbUserId;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final authUser = FirebaseAuth.instance.currentUser!;

      if (dbUserId != null) {
        await connector.resetLoginAttempts(userId: dbUserId).execute();
      }
      _resetEmailMfaFlow();

      await _completeSignIn(authUser);
    } on FirebaseAuthMultiFactorException catch (e) {
      if (mounted) {
        setState(() {
          _emailMfaPending = true;
          _emailMfaResolver = e.resolver;
          _error = '';
        });
      }
    } on FirebaseAuthException catch (e) {
      _resetEmailMfaFlow();
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        await _recordFailure(email);
      } else {
        if (mounted) {
          setState(() {
            _error = e.message ?? 'Sign in failed.';
          });
        }
      }
    } catch (_) {
      _resetEmailMfaFlow();
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmailMfa() async {
    final code = _emailMfaCodeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _submitAttempted = true;
        _error = '';
      });
      return;
    }

    final resolver = _emailMfaResolver;
    if (resolver == null) {
      setState(() {
        _error = 'Session expired. Please sign in again.';
        _resetEmailMfaFlow();
      });
      return;
    }
    final enrollmentId = _totpEnrollmentId(resolver)!;

    setState(() {
      _error = '';
      _submitAttempted = false;
      _isLoading = true;
    });

    try {
      final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
        enrollmentId,
        code,
      );
      final credential = await resolver.resolveSignIn(assertion);
      final authUser = credential.user!;

      final connector = ExampleConnector.instance;
      final dbUserId = _pendingDbUserId;
      if (dbUserId != null) {
        await connector.resetLoginAttempts(userId: dbUserId).execute();
      }
      _resetEmailMfaFlow();

      if (!mounted) return;
      await _completeSignIn(authUser);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is FirebaseAuthException
              ? (e.message ?? 'Invalid code.')
              : 'Unable to verify the code.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPhoneCode(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final fullPhone = '$_countryCode$normalized';
    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(fullPhone)) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }

    setState(() {
      _submitAttempted = false;
      _error = '';
      _isLoading = true;
      _codeSent = false;
      _verificationId = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            final authUser = FirebaseAuth.instance.currentUser!;
            await _completeSignIn(authUser);
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _error = e is FirebaseAuthException
                  ? (e.message ?? 'Phone sign-in failed.')
                  : 'Phone sign-in failed.';
              _isLoading = false;
            });
          }
        },
        verificationFailed: (e) {
          if (mounted) {
            setState(() {
              _error = e.message ?? 'Phone verification failed.';
              _isLoading = false;
            });
          }
        },
        codeSent: (verificationId, _) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to send verification code.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPhoneCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _submitAttempted = true;
        _error = '';
      });
      return;
    }

    setState(() {
      _error = '';
      _submitAttempted = false;
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final authUser = FirebaseAuth.instance.currentUser!;
      if (!mounted) return;
      await _completeSignIn(authUser);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is FirebaseAuthException
              ? (e.message ?? 'Unable to verify code.')
              : 'Unable to verify code.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeSignIn(User authUser) async {
    final connector = ExampleConnector.instance;

    final profileResult = await connector
        .getUserProfile(userId: authUser.uid)
        .execute();

    if (!mounted) return;
    if (profileResult.data.users.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, a, _) => const HomeScreen(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (r) => false,
      );
      return;
    }

    final (firstName, lastName) = _splitDisplayName(authUser.displayName);
    final (phonePrefix, phoneDigits) = _splitPhoneNumber(authUser.phoneNumber);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => StudentProfilePage(
          firstName: firstName,
          lastName: lastName,
          phonePrefix: phonePrefix,
          phoneNumber: phoneDigits,
        ),
      ),
      (r) => false,
    );
  }

  Future<void> _recordFailure(String email) async {
    try {
      final connector = ExampleConnector.instance;
      final statusResult = await connector
          .getLoginStatus(email: email)
          .execute();

      if (!mounted) return;
      if (statusResult.data.users.isEmpty) {
        setState(() => _error = 'Incorrect email or password.');
        return;
      }

      final user = statusResult.data.users.first;
      final newCount = user.failedAttempts + 1;

      Timestamp? lockUntil;
      if (newCount >= 3) {
        final unlockAt = DateTime.now().add(const Duration(minutes: 15));
        lockUntil = Timestamp(0, unlockAt.millisecondsSinceEpoch ~/ 1000);
      }

      final recordFailureBuilder = connector.recordFailedLogin(
        userId: user.userId,
        failedAttempts: newCount,
      );
      if (lockUntil != null) {
        recordFailureBuilder.lockedUntil(lockUntil);
      }
      await recordFailureBuilder.execute();

      if (!mounted) return;
      if (newCount >= 3) {
        setState(() {
          _error = 'Too many failed attempts. Account locked for 15 minutes.';
        });
        return;
      }
      final remaining = 3 - newCount;
      setState(() {
        _error =
            'Incorrect password. $remaining attempt${remaining == 1 ? '' : 's'} remaining.';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Incorrect email or password.');
      }
    }
  }

  (String, String) _splitDisplayName(String? displayName) {
    final value = displayName?.trim() ?? '';
    if (value.isEmpty) return ('Student', 'User');
    final parts = value
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) return (parts.first, 'User');
    return (parts.first, parts.sublist(1).join(' '));
  }

  (String?, String?) _splitPhoneNumber(String? number) {
    if (number == null || number.trim().isEmpty) return (null, null);
    final value = number.trim();
    final match = RegExp(r'^(\+\d{1,4})(\d{5,})$').firstMatch(value);
    if (match == null) return (null, value.replaceAll(RegExp(r'[^\d]'), ''));
    return (match.group(1), match.group(2));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final identityTrim = _identityCtrl.text.trim();

    final idError =
        _submitAttempted &&
        identityTrim.isEmpty &&
        (!_emailMfaPending || _usePhoneLogin);

    final passErr =
        _submitAttempted &&
        _passwordCtrl.text.isEmpty &&
        !_usePhoneLogin &&
        !_emailMfaPending;

    final emailMfaErr =
        _submitAttempted &&
        _emailMfaPending &&
        _emailMfaCodeCtrl.text.trim().isEmpty;

    final smsErr =
        _submitAttempted &&
        _usePhoneLogin &&
        _codeSent &&
        _codeCtrl.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
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
                  child: GestureDetector(
                    onTap: () {
                      if (_emailMfaPending) {
                        setState(() {
                          _error = '';
                          _submitAttempted = false;
                          _resetEmailMfaFlow();
                        });
                        return;
                      }
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const StartupPage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: scheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Column(
                  key: const ValueKey('login'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3e7f3f),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _setLoginChannel(false),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: !_usePhoneLogin
                                  ? const Color(0xFF3e7f3f)
                                  : Colors.transparent,
                              foregroundColor: !_usePhoneLogin
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Email'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _setLoginChannel(true),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _usePhoneLogin
                                  ? const Color(0xFF3e7f3f)
                                  : Colors.transparent,
                              foregroundColor: _usePhoneLogin
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Phone'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _usePhoneLogin
                        ? _buildPhoneInput(idError)
                        : _inputField(
                            _identityCtrl,
                            'Student Email',
                            Icons.email_outlined,
                            false,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: _emailMfaPending,
                            hasError: idError,
                          ),
                    if (!_usePhoneLogin) ...[
                      const SizedBox(height: 14),
                      _inputField(
                        _passwordCtrl,
                        'Password',
                        Icons.lock_outline,
                        true,
                        readOnly: _emailMfaPending,
                        hasError: passErr,
                      ),
                    ],
                    if (!_usePhoneLogin && _emailMfaPending) ...[
                      const SizedBox(height: 14),
                      _inputField(
                        _emailMfaCodeCtrl,
                        'Authenticator code',
                        Icons.security_outlined,
                        false,
                        keyboardType: TextInputType.number,
                        hasError: emailMfaErr,
                      ),
                    ],
                    if (_usePhoneLogin && _codeSent) ...[
                      const SizedBox(height: 14),
                      _inputField(
                        _codeCtrl,
                        'Verification code',
                        Icons.message_outlined,
                        false,
                        keyboardType: TextInputType.number,
                        hasError: smsErr,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the SMS code sent to your phone.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.75),
                          fontSize: 18,
                        ),
                      ),
                    ],
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: scheme.onErrorContainer,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error,
                                style: TextStyle(
                                  color: scheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF3e7f3f),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _usePhoneLogin
                                    ? _codeSent
                                          ? 'Verify Code'
                                          : 'Send Code'
                                    : _emailMfaPending
                                    ? 'Verify Code'
                                    : 'Sign In',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_usePhoneLogin && !_emailMfaPending) ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: scheme.primary),
                        ),
                      ),
                    ],
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 18,
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(bool identityFieldError) {
    return Row(
      children: [
        Container(
          width: 122,
          margin: EdgeInsets.zero,
          child: CountryCodePicker(
            onChanged: (country) {
              setState(() {
                _countryCode = country.dialCode ?? '+356';
              });
            },
            initialSelection: 'MT',
            favorite: const ['+356', 'MT'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
          ),
        ),
        Expanded(
          child: _inputField(
            _identityCtrl,
            'Phone number',
            Icons.phone_outlined,
            false,
            keyboardType: TextInputType.phone,
            hasError: identityFieldError,
          ),
        ),
      ],
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    bool isPass, {
    TextInputType? keyboardType,
    bool readOnly = false,
    bool hasError = false,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      obscureText: isPass ? _obscure : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 18),
      onChanged: (_) => setState(() {}),
      decoration: requiredField(
        context,
        label: label,
        hasError: hasError,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
