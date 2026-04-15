import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _obscure = true;
  String _error = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;
    final nameRegex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');

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
    if (!nameRegex.hasMatch(firstName)) {
      setState(
        () => _error = 'First name can only contain letters and spaces.',
      );
      return;
    }
    if (!nameRegex.hasMatch(lastName)) {
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
    } catch (_) {
      setState(() => _error = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscure : false,
      keyboardType: keyboardType,
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
                        Icons.arrow_back,
                        color: Color(0xFF3e7f3f),
                        size: 18,
                      ),
                      onPressed: () {
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
                    Icons.school,
                    color: Colors.white,
                    size: 48.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20.0),
                if (_error.isNotEmpty) ...[
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
                        const Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFF8B0000),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Color(0xFF8B0000),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
                _inputField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16.0),
                _inputField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16.0),
                _inputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                _inputField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 16.0),
                _inputField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 12.0),
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
                      fontSize: 14.0,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onRegister,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3e7f3f),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16.0,
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
