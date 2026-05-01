import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'forgot_password_page.dart';
import 'main.dart';
import 'onboarding_profile_page.dart';
import 'register_page.dart';
import 'startup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identityCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String _error = '';
  bool _obscure = true;
  bool _isLoading = false;
  bool _usePhoneLogin = false;
  bool _codeSent = false;
  String? _verificationId;
  String _countryCode = '+356';

  @override
  void dispose() {
    _identityCtrl.dispose();
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final identity = _identityCtrl.text.trim();
    if (identity.isEmpty) {
      setState(() => _error = 'Please fill out all fields.');
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
    final pass = _passwordCtrl.text;
    if (pass.isEmpty) {
      setState(() => _error = 'Please fill out all fields.');
      return;
    }

    setState(() {
      _error = '';
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
          setState(() {
            _error =
                'Account locked. Try again in $remaining minute${remaining == 1 ? '' : 's'}.';
            _isLoading = false;
          });
          return;
        }
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final authUser = FirebaseAuth.instance.currentUser!;

      if (dbUserId != null) {
        await connector.resetLoginAttempts(userId: dbUserId).execute();
      }

      await _completeSignIn(authUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        await _recordFailure(email);
      } else {
        setState(() {
          _error = e.message ?? 'Sign in failed.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred.';
      });
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
            final authUser = FirebaseAuth.instance.currentUser;
            if (authUser != null && mounted) {
              await _completeSignIn(authUser);
            }
          } on FirebaseAuthException catch (e) {
            if (mounted) {
              setState(() {
                _error = e.message ?? 'Phone sign-in failed.';
                _isLoading = false;
              });
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _error = 'Phone sign-in failed.';
                _isLoading = false;
              });
            }
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
      setState(() => _error = 'Enter the verification code.');
      return;
    }
    if (_verificationId == null) {
      setState(
        () =>
            _error = 'Verification data is missing. Please request a new code.',
      );
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        setState(() => _error = 'Sign-in failed. Please try again.');
        return;
      }
      await _completeSignIn(authUser);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Unable to verify code.';
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to verify code.';
      });
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
        builder: (_) => OnboardingProfilePage(
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
    } catch (e) {
      setState(() => _error = 'Incorrect email or password.');
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
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF3e7f3f),
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
                        Icons.school,
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
                            onPressed: () {
                              setState(() {
                                _usePhoneLogin = false;
                                _codeSent = false;
                                _verificationId = null;
                                _codeCtrl.clear();
                                _identityCtrl.clear();
                                _error = '';
                              });
                            },
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
                            onPressed: () {
                              setState(() {
                                _usePhoneLogin = true;
                                _codeSent = false;
                                _verificationId = null;
                                _codeCtrl.clear();
                                _identityCtrl.clear();
                                _error = '';
                              });
                            },
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
                        ? _buildPhoneInput()
                        : _inputField(
                            _identityCtrl,
                            'Student Email',
                            Icons.email_outlined,
                            false,
                            TextInputType.emailAddress,
                          ),
                    if (!_usePhoneLogin) ...[
                      const SizedBox(height: 14),
                      _inputField(
                        _passwordCtrl,
                        'Password',
                        Icons.lock_outline,
                        true,
                      ),
                    ] else if (_codeSent) ...[
                      const SizedBox(height: 14),
                      _inputField(
                        _codeCtrl,
                        'Verification code',
                        Icons.message_outlined,
                        false,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the SMS code sent to your phone.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.75),
                          fontSize: 16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _signIn,
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
                                    : 'Sign In',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_usePhoneLogin) ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 16,
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
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF3e7f3f)),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
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
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                          children: const [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3e7f3f),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPhoneInput() {
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
            TextInputType.phone,
          ),
        ),
      ],
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    bool isPass, [
    TextInputType? keyboardType,
  ]) {
    return TextField(
      controller: ctrl,
      obscureText: isPass ? _obscure : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
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
    );
  }
}
