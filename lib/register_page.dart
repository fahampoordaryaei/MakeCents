import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'onboarding_profile_page.dart';
import 'startup_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool _obscure = true;
  String _error = '';
  bool _isLoading = false;
  bool _usePhoneRegister = false;
  bool _codeSent = false;
  String? _verificationId;
  String _countryCode = '+356';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _validateNames() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final nameRegex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _error = 'Please fill out all fields.');
      return false;
    }
    if (!nameRegex.hasMatch(firstName)) {
      setState(
        () => _error = 'First name can only contain letters and spaces.',
      );
      return false;
    }
    if (!nameRegex.hasMatch(lastName)) {
      setState(() => _error = 'Last name can only contain letters and spaces.');
      return false;
    }
    return true;
  }

  /// Same as login: phone OTP success does not complete registration / onboarding.
  Future<void> _placeholderSuccess() async {
    if (!mounted) return;
    setState(() => _isLoading = false);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your phone number was verified successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() {
      _codeSent = false;
      _verificationId = null;
      _codeController.clear();
      _error = '';
    });
  }

  Future<void> _completePhoneRegistration(UserCredential result) async {
    if (!mounted || !_usePhoneRegister) return;
    if (result.additionalUserInfo?.isNewUser == false) {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _error = 'An account already exists for this phone number.';
        _isLoading = false;
      });
      return;
    }
    await _placeholderSuccess();
  }

  Future<void> _sendPhoneRegister() async {
    if (!_usePhoneRegister) return;
    if (!_validateNames()) return;

    final normalized = _phoneController.text.trim().replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );
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
          if (!mounted || !_usePhoneRegister) return;
          try {
            final result = await FirebaseAuth.instance.signInWithCredential(
              credential,
            );
            if (!mounted || !_usePhoneRegister) return;
            await _completePhoneRegistration(result);
          } on FirebaseAuthException catch (e) {
            if (!mounted || !_usePhoneRegister) return;
            setState(() {
              _error = e.message ?? 'Phone registration failed.';
              _isLoading = false;
            });
          } catch (e) {
            debugPrint('register: verificationCompleted signIn failed: $e');
            if (!mounted || !_usePhoneRegister) return;
            setState(() {
              _error = 'Phone registration failed.';
              _isLoading = false;
            });
          }
        },
        verificationFailed: (e) {
          if (!mounted || !_usePhoneRegister) return;
          setState(() {
            _error = e.message ?? 'Phone verification failed.';
            _isLoading = false;
          });
        },
        codeSent: (verificationId, _) {
          if (!mounted || !_usePhoneRegister) return;
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!_usePhoneRegister) return;
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('register: sendPhoneRegister failed: $e');
      if (!mounted || !_usePhoneRegister) return;
      setState(() {
        _error = 'Unable to send verification code.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPhoneRegister() async {
    if (!_usePhoneRegister) return;
    if (!_validateNames()) return;

    final code = _codeController.text.trim();
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
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      await _completePhoneRegistration(result);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Unable to verify code.');
      }
    } catch (e) {
      debugPrint('register: verifyPhoneRegister failed: $e');
      if (mounted) setState(() => _error = 'Unable to verify code.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRegister() async {
    if (_usePhoneRegister) {
      await _registerWithPhone();
    } else {
      await _registerWithEmail();
    }
  }

  Future<void> _registerWithEmail() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    setState(() => _error = '');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        pass.isEmpty ||
        confirmPass.isEmpty) {
      setState(() => _error = 'Please fill out all fields.');
      return;
    }
    if (pass != confirmPass) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(firstName)) {
      setState(
        () => _error = 'First name can only contain letters and spaces.',
      );
      return;
    }
    if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(lastName)) {
      setState(() => _error = 'Last name can only contain letters and spaces.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (pass.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters long.');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(pass)) {
      setState(
        () => _error = 'Password must contain at least 1 uppercase letter.',
      );
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(pass)) {
      setState(
        () => _error = 'Password must contain at least 1 lowercase letter.',
      );
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(pass)) {
      setState(() => _error = 'Password must contain at least 1 number.');
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(pass)) {
      setState(
        () => _error = 'Password must contain at least 1 special character.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authMethods = await FirebaseAuth.instance
          // ignore: deprecated_member_use
          .fetchSignInMethodsForEmail(email);

      if (authMethods.isNotEmpty) {
        final inDb =
            (await ExampleConnector.instance
                    .getLoginStatus(email: email)
                    .execute())
                .data
                .users
                .isNotEmpty;
        if (inDb) {
          if (mounted) {
            setState(
              () => _error = 'This email is already in use. Sign in instead.',
            );
          }
          return;
        }
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: pass,
          );
        } on FirebaseAuthException catch (e) {
          if (mounted) {
            setState(
              () => _error =
                  e.code == 'wrong-password' || e.code == 'invalid-credential'
                  ? 'Incorrect password for this account. Use Sign in.'
                  : (e.message ?? 'Could not register with this email.'),
            );
          }
          return;
        }
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          '$firstName $lastName',
        );
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnboardingProfilePage(
                firstName: firstName,
                lastName: lastName,
              ),
            ),
          );
        }
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      await userCredential.user?.updateDisplayName('$firstName $lastName');

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                OnboardingProfilePage(firstName: firstName, lastName: lastName),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(
        () => _error = e.message ?? 'An error occurred during registration.',
      );
    } catch (e) {
      debugPrint('register: registerWithEmail unexpected error: $e');
      setState(() => _error = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithPhone() async {
    if (_codeSent) {
      await _verifyPhoneRegister();
    } else {
      await _sendPhoneRegister();
    }
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
            controller: _phoneController,
            label: 'Phone number',
            icon: Icons.phone_outlined,
            isPassword: false,
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscure : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
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
                const SizedBox(height: 8),
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
                  'Create an account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Finance tracker for students',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 28),
                _inputField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                _inputField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _usePhoneRegister = false;
                            _codeSent = false;
                            _verificationId = null;
                            _phoneController.clear();
                            _codeController.clear();
                            _error = '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !_usePhoneRegister
                              ? const Color(0xFF3e7f3f)
                              : Colors.transparent,
                          foregroundColor: !_usePhoneRegister
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
                            _usePhoneRegister = true;
                            _codeSent = false;
                            _verificationId = null;
                            _emailController.clear();
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                            _codeController.clear();
                            _error = '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _usePhoneRegister
                              ? const Color(0xFF3e7f3f)
                              : Colors.transparent,
                          foregroundColor: _usePhoneRegister
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
                if (!_usePhoneRegister) ...[
                  _inputField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _inputField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 14),
                  _inputField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password must contain:\n'
                      '• Min 8 characters\n'
                      '• 1 uppercase letter\n'
                      '• 1 lowercase letter\n'
                      '• 1 number\n'
                      '• 1 special character',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                  ),
                ] else ...[
                  _buildPhoneInput(),
                  if (_codeSent) ...[
                    const SizedBox(height: 14),
                    _inputField(
                      controller: _codeController,
                      label: 'Verification code',
                      icon: Icons.message_outlined,
                      keyboardType: TextInputType.number,
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
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _onRegister,
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
                            _usePhoneRegister
                                ? _codeSent
                                      ? 'Verify Code'
                                      : 'Send Code'
                                : 'Continue',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
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
}
