import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'startup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpCtrls     = List.generate(4, (_) => TextEditingController());
  final _otpFocus     = List.generate(4, (_) => FocusNode());
  String _error = '';
  bool _show2fa = false;
  bool _obscure = true;
  int _fails = 0;
  DateTime? _lockedUntil;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    for (var f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  void _signIn() {
    setState(() {
      if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
        _error = 'Account locked until ${DateFormat.Hms().format(_lockedUntil!.toLocal())}';
        return;
      }
      final email = _emailCtrl.text.trim();
      final pass  = _passwordCtrl.text;
      if (email.isEmpty || pass.isEmpty) { _error = 'Please fill out all fields.'; return; }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) { _error = 'Please enter a valid email address.'; return; }

      const hardUser = 'admin@example.com';
      const hardPass = 'PASSWORD1234!';

      if (email.toLowerCase() != hardUser.toLowerCase() || pass != hardPass) {
        _fails++;
        if (_fails >= 3) {
          _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
          _error = 'Too many failed attempts. Locked until ${DateFormat.Hms().format(_lockedUntil!.toLocal())}';
        } else {
          _error = email.toLowerCase() != hardUser.toLowerCase()
              ? 'Student not found. ${3 - _fails} attempts remaining.'
              : 'Invalid credentials. ${3 - _fails} attempts remaining.';
        }
        return;
      }
      _fails = 0; _error = ''; _show2fa = true;
      WidgetsBinding.instance.addPostFrameCallback((_) { if (_otpFocus.isNotEmpty) _otpFocus[0].requestFocus(); });
    });
=======
  Future<void> _onSignInPressed() async {
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      setState(() {
        final fmt = DateFormat.Hms();
        _errorMessage =
            "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill out all fields.';
      });
      return;
    }

    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

=======
  Future<void> _onSignInPressed() async {
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      setState(() {
        final fmt = DateFormat.Hms();
        _errorMessage =
            "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill out all fields.';
      });
      return;
    }

    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

>>>>>>> Stashed changes
=======
  Future<void> _onSignInPressed() async {
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      setState(() {
        final fmt = DateFormat.Hms();
        _errorMessage =
            "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill out all fields.';
      });
      return;
    }

    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

>>>>>>> Stashed changes
      setState(() {
        _failedAttempts = 0;
        _errorMessage = '';
        _show2fa = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_otpFocusNodes.isNotEmpty) _otpFocusNodes[0].requestFocus();
      });
    } on FirebaseAuthException catch (_) {
      setState(() {
        _failedAttempts += 1;
        if (_failedAttempts >= 3) {
          _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
          final fmt = DateFormat.Hms();
          _errorMessage =
              "Too many failed attempts. Your account is locked until ${fmt.format(_lockedUntil!.toLocal())}";
        } else {
          final remaining = 3 - _failedAttempts;
          _errorMessage = 'Invalid credentials. $remaining attempts remaining.';
        }
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
      });
    }
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
      _otpControllers[index].text = digits;
      _otpControllers[index].selection = const TextSelection.collapsed(
        offset: 1,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index < 3) {
          _otpFocusNodes[index + 1].requestFocus();
        } else {
          _otpFocusNodes[index].unfocus();
        }
>>>>>>> Stashed changes
      });
    }
>>>>>>> Stashed changes
  }

  void _verifyOtp() {
    setState(() {
      final code = _otpCtrls.map((c) => c.text).join();
      if (code.length < 4) { _error = 'Please enter the 4-digit code.'; return; }
      if (code == '1234') {
        _error = '';
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const HomeScreen(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ), (r) => false);
      } else {
        _error = 'Invalid 2FA code.';
        for (var c in _otpCtrls) {
          c.clear();
        }
        _otpFocus[0].requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Align(alignment: Alignment.centerLeft, child: _backBtn()),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _show2fa ? _build2fa() : _buildLogin(),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFFECEC), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Color(0xFF8B0000), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error, style: const TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.w600, fontSize: 13))),
                  ]),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _backBtn() => GestureDetector(
    onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StartupPage())),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: const Color(0xFFF4F7F5), shape: BoxShape.circle),
      child: const Icon(Icons.arrow_back, color: Color(0xFF3e7f3f), size: 18),
    ),
  );

  Widget _buildLogin() => Column(key: const ValueKey('login'), mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF3e7f3f), borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.school, color: Colors.white, size: 40)),
    const SizedBox(height: 24),
    const Text('Welcome Back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
    const SizedBox(height: 6),
    const Text('Student Finance Tracker', style: TextStyle(fontSize: 14, color: Colors.grey)),
    const SizedBox(height: 28),
    _inputField(_emailCtrl, 'Student Email', Icons.email_outlined, false),
    const SizedBox(height: 14),
    _inputField(_passwordCtrl, 'Password', Icons.lock_outline, true),
    const SizedBox(height: 24),
    SizedBox(width: double.infinity, child: FilledButton(
      onPressed: _signIn,
      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3e7f3f),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    )),
  ]);

  Widget _inputField(TextEditingController ctrl, String label, IconData icon, bool isPass) {
    return TextField(
      controller: ctrl,
      obscureText: isPass ? _obscure : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPass ? IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ) : null,
        filled: true, fillColor: const Color(0xFFF4F7F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _build2fa() => Column(key: const ValueKey('2fa'), mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEEFBF1), borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.phone_android, color: Color(0xFF3e7f3f), size: 40)),
    const SizedBox(height: 24),
    const Text('Two-Factor Auth', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
    const SizedBox(height: 6),
    const Text("We've sent a 4-digit code to your phone.", style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
    const SizedBox(height: 28),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (i) => SizedBox(
      width: 62,
      child: TextFormField(
        controller: _otpCtrls[i],
        focusNode: _otpFocus[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          filled: true, fillColor: const Color(0xFFF4F7F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            if (i + 1 < _otpFocus.length) {
              _otpFocus[i + 1].requestFocus();
            } else {
              _otpFocus[i].unfocus();
            }
            final code = _otpCtrls.map((c) => c.text).join();
            if (code.length == 4) _verifyOtp();
          } else {
            if (i > 0) {
              _otpFocus[i - 1].requestFocus();
            }
          }
        },
      ),
    ))),
  ]);
}
