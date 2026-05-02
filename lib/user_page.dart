import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';
import 'onboarding_profile_form.dart';
import 'login_page.dart';
import 'theme_provider.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';

String _profileStoreEmail(User user) {
  final email = user.email?.trim();
  if (email != null && email.isNotEmpty) return email;
  final phone = user.phoneNumber?.trim();
  if (phone != null && phone.isNotEmpty) return phone;
  return '';
}

Future<int?> _getCountryId(ExampleConnector connector, String? isoCode) async {
  final code = isoCode?.trim().toUpperCase();
  if (code == null || code.length != 2) return null;
  try {
    final result = await connector.getCountryIdByCode(code: code).execute();
    final matches = result.data.countries;
    if (matches.isEmpty) return null;
    return matches.first.id;
  } catch (_) {
    return null;
  }
}

class UserPage extends StatelessWidget {
  final VoidCallback onNavigateToBudget;
  const UserPage({super.key, required this.onNavigateToBudget});

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email associated with this account.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Change password'),
        content: Text(
          'We will email a password reset link to:\n$email\n\n'
          'Open it to set a new password.',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(100, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3e7f3f),
              minimumSize: const Size(100, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Send email'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to send reset email.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send reset email.')),
      );
    }
  }

  Future<void> _openSettingsMenu(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsPage(
          onChangePassword: _showChangePasswordDialog,
          onDeleteAccount: _confirmDeleteAccount,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;

      AuthCredential? credential;
      if (user.phoneNumber?.isNotEmpty ?? false) {
        credential = await showDialog<PhoneAuthCredential>(
          context: context,
          builder: (_) =>
              _DeleteAccountPhoneCodeDialog(phoneNumber: user.phoneNumber!),
        );
        if (credential == null) return;
      } else {
        final password = await showDialog<String>(
          context: context,
          builder: (_) => const _DeleteAccountPasswordDialog(),
        );
        if (password == null || password.isEmpty) return;
        final email = user.email;
        if (email == null || email.isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No email associated with this account.'),
            ),
          );
          return;
        }
        credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
      }

      await user.reauthenticateWithCredential(credential);

      await ExampleConnector.instance
          .deleteUserProfile(userId: user.uid)
          .execute();

      await user.delete();

      if (!context.mounted) return;
      Provider.of<UserProvider>(context, listen: false).clearProfile();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (r) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete account.')),
      );
    }
  }

  Future<void> _editBudgetDialog(BuildContext context) async {
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    await showDialog<void>(
      context: context,
      builder: (_) =>
          _EditBudgetDialog(bp: bp, initialAmount: bp.budget.amount),
    );
  }

  Future<void> _editInstitutionProfileDialog(BuildContext context) async {
    final up = Provider.of<UserProvider>(context, listen: false);
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final profile = up.profile;
    if (profile == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _EditInstitutionProfileDialog(profile: profile, bp: bp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _signedInBody(context, user);
      },
    );
  }

  Widget _signedInBody(BuildContext context, User user) {
    final txP = Provider.of<TransactionProvider>(context);
    final bp = Provider.of<BudgetProvider>(context);
    final tp = Provider.of<ThemeProvider>(context);
    final up = Provider.of<UserProvider>(context);
    final isDarkMode = tp.themeMode != ThemeModes.light;
    final totalSpent = txP.periodSpent(isWeekly: bp.isWeekly);

    final userContact =
        user.phoneNumber ?? up.profile?.email ?? user.email ?? '';
    final userName = up.profile?.fullName ?? user.displayName ?? '';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userContact,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (up.profile != null &&
                      up.profile!.displayInstitution != 'Not set') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3e7f3f).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        up.profile!.displayInstitution,
                        style: const TextStyle(
                          color: Color(0xFF3e7f3f),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Total Spent',
                    formatMoney(totalSpent),
                    Icons.arrow_upward_rounded,
                    const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    'Expenses',
                    '${txP.transactions.length}',
                    Icons.receipt_long_outlined,
                    const Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF3e7f3f),
              title: 'Student Profile',
              subtitle:
                  '${up.profile!.displayInstitution} • ${up.profile!.displayCourse}',
              onTap: () => _editInstitutionProfileDialog(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF3e7f3f),
              title: '${bp.periodLabel} Budget',
              subtitle: formatMoney(bp.budget.amount),
              onTap: () => _editBudgetDialog(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.deepPurple,
              title: 'Dark Mode',
              subtitle: 'Toggle dark mode',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (val) {
                  tp.setTheme(val ? ThemeModes.dark : ThemeModes.light);
                },
                activeThumbColor: const Color(0xFF3e7f3f),
              ),
              onTap: () {
                tp.setTheme(isDarkMode ? ThemeModes.light : ThemeModes.dark);
              },
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF4ECDC4),
              title: 'Settings',
              subtitle: 'Account settings',
              onTap: () => _openSettingsMenu(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.logout_outlined,
              iconColor: const Color(0xFFFF6B6B),
              title: 'Log Out',
              subtitle: 'Sign out of your account',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).clearProfile();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (r) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountPasswordDialog extends StatefulWidget {
  const _DeleteAccountPasswordDialog();

  @override
  State<_DeleteAccountPasswordDialog> createState() =>
      _DeleteAccountPasswordDialogState();
}

class _DeleteAccountPhoneCodeDialog extends StatefulWidget {
  final String phoneNumber;
  const _DeleteAccountPhoneCodeDialog({required this.phoneNumber});

  @override
  State<_DeleteAccountPhoneCodeDialog> createState() =>
      _DeleteAccountPhoneCodeDialogState();
}

class _DeleteAccountPhoneCodeDialogState
    extends State<_DeleteAccountPhoneCodeDialog> {
  final TextEditingController _codeCtrl = TextEditingController();
  String _error = '';
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _error = '');
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) {
          if (!mounted) return;
          Navigator.of(context).pop(credential);
        },
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() {
            _error = e.message ?? 'Could not send verification code.';
          });
        },
        codeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not send verification code.');
    }
  }

  void _confirm() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the verification code.');
      return;
    }
    if (_verificationId == null) {
      setState(() => _error = 'Verification expired. Request a new code.');
      return;
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );
    Navigator.of(context).pop(credential);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Delete account?'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the SMS code sent to ${widget.phoneNumber} to confirm account deletion.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Verification code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _error,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: _sendCode,
          child: const Text('Resend'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: _confirm,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _DeleteAccountPasswordDialogState
    extends State<_DeleteAccountPasswordDialog> {
  late final TextEditingController _passwordCtrl;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('This will permanently remove your account.'),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context, _passwordCtrl.text.trim()),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _EditBudgetDialog extends StatefulWidget {
  final BudgetProvider bp;
  final double initialAmount;

  const _EditBudgetDialog({required this.bp, required this.initialAmount});

  @override
  State<_EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<_EditBudgetDialog> {
  late final TextEditingController _ctrl;
  late double _sliderVal;
  late bool _isWeekly;
  List<ListCurrenciesCurrencies> _currencies = const [];
  ListCurrenciesCurrencies? _selectedCurrency;
  String _dialogError = '';

  @override
  void initState() {
    super.initState();
    final v = widget.initialAmount;
    _ctrl = TextEditingController(text: v.toStringAsFixed(0));
    _sliderVal = v.clamp(10.0, 10000.0);
    _isWeekly = widget.bp.isWeekly;
    _loadCurrencies();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final val = double.tryParse(_ctrl.text.trim());
    setState(() {
      if (val != null && val >= 10 && val <= 10000) {
        if (_sliderVal != val) {
          _sliderVal = val;
        }
      } else if (val != null && val > 10000) {
        _sliderVal = 10000;
      }
    });
  }

  Future<void> _loadCurrencies() async {
    try {
      final result = await ExampleConnector.instance.listCurrencies().execute();
      if (!mounted) return;
      final list = result.data.currencies;
      if (list.isEmpty) return;
      final selected = list.firstWhere(
        (c) => c.id == currencyId,
        orElse: () => list.firstWhere(
          (c) => c.code.trim().toUpperCase() == 'EUR',
          orElse: () => list.first,
        ),
      );
      setState(() {
        _currencies = list;
        _selectedCurrency = selected;
      });
    } catch (_) {}
  }

  void _onCurrencyChanged(ListCurrenciesCurrencies c) {
    setState(() => _selectedCurrency = c);
    setGlobalCurrency(sign: c.sign, id: c.id);
  }

  String get _sign => _selectedCurrency?.sign ?? currency;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        'Update Budget',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_dialogError.isNotEmpty) ...[
              Text(
                _dialogError,
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('Monthly')),
                ButtonSegment<bool>(value: true, label: Text('Weekly')),
              ],
              selected: {_isWeekly},
              onSelectionChanged: (s) => setState(() => _isWeekly = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              onChanged: (_) => _onTextChanged(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: '0',
                prefix: _buildCurrencyDropdown(context),
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
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF3e7f3f),
                inactiveTrackColor: const Color(
                  0xFF3e7f3f,
                ).withValues(alpha: 0.2),
                thumbColor: const Color(0xFF3e7f3f),
                trackHeight: 6.0,
              ),
              child: Slider(
                value: _sliderVal,
                min: 10,
                max: 10000,
                divisions: 100,
                onChanged: (v) {
                  setState(() {
                    _sliderVal = v;
                    _ctrl.text = v.toInt().toString();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_sign}10',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${_sign}10,000',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3e7f3f),
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            final v = double.tryParse(_ctrl.text.trim());
            if (v == null || v < 10) {
              setState(
                () => _dialogError = 'The minimum budget is ${_sign}10.',
              );
              return;
            }
            if (v > 10000) {
              setState(() => _dialogError = 'Max budget is ${_sign}10,000.');
              return;
            }
            final selectedCurrencyId = _selectedCurrency?.id;
            if (selectedCurrencyId != null) {
              await ExampleConnector.instance
                  .updateUserCurrency(
                    userId: FirebaseAuth.instance.currentUser!.uid,
                    currencyId: selectedCurrencyId,
                  )
                  .execute();
            }
            await widget.bp.setBudget(v, isWeekly: _isWeekly);
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 32,
      fontWeight: FontWeight.w900,
    );

    final divider = Container(
      width: 3,
      height: 32,
      margin: const EdgeInsets.only(left: 8, right: 12),
      color: const Color(0xFF7B7B7B),
    );

    if (_currencies.length < 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_sign, style: textStyle),
          divider,
        ],
      );
    }

    return PopupMenuButton<ListCurrenciesCurrencies>(
      tooltip: 'Change currency',
      position: PopupMenuPosition.under,
      onSelected: _onCurrencyChanged,
      itemBuilder: (context) => [
        for (final c in _currencies)
          PopupMenuItem<ListCurrenciesCurrencies>(
            value: c,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    c.sign,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(c.code.trim()),
                if (c.id == _selectedCurrency?.id) ...[
                  const Spacer(),
                  const Icon(Icons.check, size: 18, color: Color(0xFF3e7f3f)),
                ],
              ],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_sign, style: textStyle),
          Icon(
            Icons.arrow_drop_down,
            size: 36,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          divider,
        ],
      ),
    );
  }
}

class _EditInstitutionProfileDialog extends StatefulWidget {
  final UserProfile profile;
  final BudgetProvider bp;

  const _EditInstitutionProfileDialog({
    required this.profile,
    required this.bp,
  });

  @override
  State<_EditInstitutionProfileDialog> createState() =>
      _EditInstitutionProfileDialogState();
}

class _EditInstitutionProfileDialogState
    extends State<_EditInstitutionProfileDialog> {
  final GlobalKey<OnboardingProfileFormState> _formKey =
      GlobalKey<OnboardingProfileFormState>();
  String _error = '';
  bool _saving = false;

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;

    setState(() {
      _error = '';
      _saving = true;
    });

    final msg = form.validate();
    if (msg != null) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    final selection = form.buildSelection();

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final connector = ExampleConnector.instance;

      int? countryId;
      if (selection.countryIsoCode != null) {
        countryId = await _getCountryId(connector, selection.countryIsoCode);
      }

      final base = connector.storeUserProfile(
        userId: user.uid,
        email: _profileStoreEmail(user),
        firstName: widget.profile.firstName,
        lastName: widget.profile.lastName,
      );

      var cmd = base
          .institutionId(selection.institutionId)
          .courseId(selection.courseId)
          .otherInstitution(selection.otherInstitution)
          .otherCourse(selection.otherCourse)
          .budget(widget.bp.budget.amount)
          .isWeekly(widget.bp.isWeekly);
      if (countryId != null) {
        cmd = cmd.countryId(countryId);
      }
      final cid = currencyId;
      if (cid != null) {
        cmd = cmd.currencyId(cid);
      }
      await cmd.execute();

      if (!mounted) return;
      final budgetProvider = context.read<BudgetProvider>();
      final userProvider = context.read<UserProvider>();
      await budgetProvider.init();
      await userProvider.loadProfile();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not save. Please try again.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _formKey.currentState?.canSubmit == true && !_saving;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        'Student Profile',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error.isNotEmpty) ...[
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              OnboardingProfileForm(
                key: _formKey,
                initialProfile: widget.profile,
                onUpdated: () {
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3e7f3f),
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: canSave ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsPage extends StatelessWidget {
  final Future<void> Function(BuildContext context) onChangePassword;
  final Future<void> Function(BuildContext context) onDeleteAccount;

  const _SettingsPage({
    required this.onChangePassword,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (FirebaseAuth.instance.currentUser!.providerData.any(
                (p) => p.providerId == 'password',
              )) ...[
                _SettingsTile(
                  icon: Icons.lock_outline,
                  iconColor: const Color(0xFF4ECDC4),
                  title: 'Change password',
                  subtitle: 'Send a password reset email',
                  onTap: () => onChangePassword(context),
                ),
                const SizedBox(height: 8),
              ],
              _SettingsTile(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFFF6B6B),
                title: 'Delete account',
                subtitle: 'Permanently remove your account',
                onTap: () => onDeleteAccount(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
    ),
  );
}
