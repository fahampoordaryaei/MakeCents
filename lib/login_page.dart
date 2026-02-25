import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _show2fa = false;

  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());
  bool _isHandlingOtp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onSignInPressed() {
    setState(() {
      // Check lock
      if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
        final fmt = DateFormat.Hms();
        _errorMessage = "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Please fill out all fields.';
        return;
      }

      // Hardcoded login (use real-looking email)
      const hardUser = 'admin@example.com';
      const hardPass = 'Password1234!';

      // Email format validation
      final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      final isEmailLike = emailPattern.hasMatch(email);

      if (!isEmailLike) {
        _errorMessage = 'Please enter a valid email address.';
        return;
      }

      // If the email is valid format but doesn't match our single user
      if (email.toLowerCase() != hardUser.toLowerCase()) {
        _failedAttempts += 1;
        if (_failedAttempts >= 3) {
          _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
          final fmt = DateFormat.Hms();
          _errorMessage = "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
        } else {
          final remaining = 3 - _failedAttempts;
          _errorMessage = 'Student not found. $remaining attempts remaining.';
        }
        return;
      }

      // At this point email matches hardUser
      if (password == hardPass) {
        // success -> reset attempts and show 2FA
        _failedAttempts = 0;
        _errorMessage = '';
        _show2fa = true;
        // focus the first OTP after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_otpFocusNodes.isNotEmpty) _otpFocusNodes[0].requestFocus();
        });
      } else {
        _failedAttempts += 1;
        if (_failedAttempts >= 3) {
          _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
          final fmt = DateFormat.Hms();
          _errorMessage = "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
        } else {
          final remaining = 3 - _failedAttempts;
          _errorMessage = 'Invalid credentials. $remaining attempts remaining.';
        }
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (_isHandlingOtp) return;
    _isHandlingOtp = true;

    // Keep only digits
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      // If the field became empty, move focus back
      if (index > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _otpFocusNodes[index - 1].requestFocus();
        });
      }
      _isHandlingOtp = false;
      return;
    }

    if (digits.length == 1) {
      // Normal single-digit entry
      _otpControllers[index].text = digits;
      _otpControllers[index].selection = const TextSelection.collapsed(offset: 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index < 3) {
          _otpFocusNodes[index + 1].requestFocus();
        } else {
          _otpFocusNodes[index].unfocus();
        }
      });

      // If all fields are filled now, auto-verify
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final allFilled = _otpControllers.every((c) => c.text.isNotEmpty);
        if (allFilled) _verifyOtpAndContinue();
      });

      _isHandlingOtp = false;
      return;
    }

    // More than one digit was entered (paste or fast typing) -> distribute
    int i = index;
    for (final ch in digits.split('')) {
      if (i >= _otpControllers.length) break;
      _otpControllers[i].text = ch;
      i++;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (i < _otpFocusNodes.length) {
        _otpFocusNodes[i].requestFocus();
      } else {
        _otpFocusNodes.last.unfocus();
      }

      // Auto-verify if all fields now filled
      final allFilled = _otpControllers.every((c) => c.text.isNotEmpty);
      if (allFilled) _verifyOtpAndContinue();
    });

    _isHandlingOtp = false;
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC), // chosen light red
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF8B0000),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: const TextStyle(
                color: Color(0xFF8B0000),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // (error banner moved to container header)
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF3e7f3f),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(
            Icons.school,
            color: Colors.white,
            size: 48.0,
          ),
        ),
        const SizedBox(height: 30.0),
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'The Student Finance Tracker',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Student Email',
          ),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _onSignInPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3e7f3f),
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In  ',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
        // moved banner above
      ],
    );
  }

  Widget _build2faForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // (error banner moved to container header)
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFeefbf1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(
            Icons.phone_android,
            color: Color(0xFF3e7f3f),
            size: 48.0,
          ),
        ),
        const SizedBox(height: 30.0),
        const Text(
          'Two-Factor Authentication',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'We\'ve sent a 4-digit code to your phone.',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 64,
              child: Focus(
                focusNode: _otpFocusNodes[index],
                onKey: (node, event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                    final text = _otpControllers[index].text;
                    if (text.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                      _otpControllers[index - 1].text = '';
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: TextFormField(
                  controller: _otpControllers[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _onOtpChanged(index, value);
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _verifyOtpAndContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3e7f3f),
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verify & Continue',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        // Back to login removed; use banner/navigator instead
      ],
    );
  }

  void _verifyOtpAndContinue() {
    setState(() {
      final code = _otpControllers.map((c) => c.text).join();
      if (code.length < 4) {
        _errorMessage = 'Please enter the 4-digit code.';
        return;
      }
      if (code == '1234') {
        _errorMessage = '';
        // Navigate to Home with fade and remove all routes
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      } else {
        _errorMessage = 'Invalid 2FA code.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeefbf1),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Persistent top-left return button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF3e7f3f), size: 18),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _show2fa ? _build2faForm() : _buildLoginForm(),
                ),
                if (_errorMessage.isNotEmpty) _buildErrorBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
