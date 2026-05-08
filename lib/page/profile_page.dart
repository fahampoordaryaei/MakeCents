import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/helper/scholarship_helper.dart';
import 'package:makecents/helper/ui_helper.dart';
import 'package:makecents/helper/currency_helper.dart';
import 'package:makecents/page/login_page.dart';
import 'package:makecents/provider/budget_provider.dart';
import 'package:makecents/provider/mfa_provider.dart';
import 'package:makecents/provider/theme_provider.dart';
import 'package:makecents/provider/transaction_provider.dart';
import 'package:makecents/provider/user_provider.dart';
import 'package:makecents/widget/busy_button.dart';
import 'package:makecents/widget/student_profile_widget.dart';

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

class ProfilePage extends StatelessWidget {
  final VoidCallback onNavigateToBudget;
  const ProfilePage({super.key, required this.onNavigateToBudget});

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Change password',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 420,
            child: Text(
              'A link to change your password will be sent to your email address:\n$email',
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(100, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(fontSize: 18)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3e7f3f),
                minimumSize: const Size(100, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Send email', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      await popupAlert(
        context,
        message: 'Password reset email sent to $email.',
        level: AppAlertLevel.success,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      await popupAlert(
        context,
        message: e.message ?? 'Failed to send reset email.',
        level: AppAlertLevel.error,
      );
    } catch (_) {
      if (!context.mounted) return;
      await popupAlert(
        context,
        message: 'Failed to send reset email.',
        level: AppAlertLevel.error,
      );
    }
  }

  Future<void> _openSettingsMenu(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsPage(
          onChangePassword: _showChangePasswordDialog,
          onMfa: (ctx) => showMfaAccountDialog(ctx),
          onDeleteAccount: _confirmDeleteAccount,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;

      Future<void> deleteWith(AuthCredential credential) async {
        await user.reauthenticateWithCredential(credential);
        await ExampleConnector.instance
            .deleteUserProfile(userId: user.uid)
            .execute();
        await user.delete();
      }

      final bool? deleted;
      if (user.phoneNumber?.isNotEmpty ?? false) {
        deleted = await showDialog<bool>(
          context: context,
          builder: (_) => _DeleteByPhoneDialog(
            phoneNumber: user.phoneNumber!,
            runDeletion: deleteWith,
          ),
        );
      } else {
        Future<void> deleteWithEmail(String password, String totpCode) async {
          final email = user.email!.trim();
          await reauthenticateUser(
            user: user,
            email: email,
            password: password,
            totpForSignIn: totpCode,
          );
          await ExampleConnector.instance
              .deleteUserProfile(userId: user.uid)
              .execute();
          await user.delete();
        }

        deleted = await showDialog<bool>(
          context: context,
          builder: (_) => _DeleteByPasswordDialog(
            emailVerified: user.emailVerified,
            runEmailDeletion: deleteWithEmail,
          ),
        );
      }

      if (deleted == true && context.mounted) {
        Provider.of<UserProvider>(context, listen: false).clearProfile();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false,
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      await popupAlert(
        context,
        message: 'Could not delete account.',
        level: AppAlertLevel.error,
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

  Future<void> _editStudentProfileDialog(BuildContext context) async {
    final up = Provider.of<UserProvider>(context, listen: false);
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final profile = up.profile;
    if (profile == null) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _EditProfileDialog(profile: profile, bp: bp),
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
          return const Center(child: CircularProgressIndicator());
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Total Spent',
                    formatMoney(totalSpent),
                    Icons.arrow_upward_rounded,
                    const Color(0xFFF87171),
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
            const SizedBox(height: 20),
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
                  '${up.profile?.displayInstitution ?? 'Not set'} • ${up.profile?.displayCourse ?? 'Not set'}',
              onTap: () => _editStudentProfileDialog(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF3e7f3f),
              title: 'Budget',
              subtitle: formatMoney(bp.budget.amount),
              onTap: () => _editBudgetDialog(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              iconColor: Colors.deepPurple,
              title: 'Theme',
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
              title: 'Account Settings',
              subtitle: 'Account settings',
              onTap: () => _openSettingsMenu(context),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.logout_outlined,
              iconColor: const Color(0xFFF87171),
              title: 'Sign Out',
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

class _DeleteByPasswordDialog extends StatefulWidget {
  final bool emailVerified;
  final Future<void> Function(String password, String authenticatorCode)
  runEmailDeletion;

  const _DeleteByPasswordDialog({
    required this.emailVerified,
    required this.runEmailDeletion,
  });

  @override
  State<_DeleteByPasswordDialog> createState() =>
      _DeleteByPasswordDialogState();
}

class _DeleteByPhoneDialog extends StatefulWidget {
  final String phoneNumber;
  final Future<void> Function(AuthCredential credential) runDeletion;

  const _DeleteByPhoneDialog({
    required this.phoneNumber,
    required this.runDeletion,
  });

  @override
  State<_DeleteByPhoneDialog> createState() => _DeleteByPhoneDialogState();
}

class _DeleteByPhoneDialogState extends State<_DeleteByPhoneDialog> {
  final TextEditingController _codeCtrl = TextEditingController();
  String _error = '';
  String? _verificationId;
  bool _codeAttempted = false;
  bool _busy = false;
  bool _smsStep = false;
  bool _sentCode = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _onFirstConfirm() {
    if (_busy) return;
    setState(() {
      _smsStep = true;
    });
    _sendCode();
  }

  Future<void> _sendCode() async {
    if (_busy || _sentCode) return;
    setState(() {
      _error = '';
      _codeAttempted = false;
      _sentCode = true;
      _verificationId = null;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) {
          Future.microtask(() async {
            if (!mounted) return;
            setState(() {
              _sentCode = false;
              _busy = true;
            });
            try {
              await widget.runDeletion(credential);
              if (!mounted) return;
              Navigator.of(context).pop(true);
            } catch (e) {
              if (!mounted) return;
              setState(() {
                _busy = false;
                _error = _deleteAuthErrorMessage(e);
              });
            }
          });
        },
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() {
            _sentCode = false;
            _error = e.message ?? 'Could not send verification code.';
          });
        },
        codeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _sentCode = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _sentCode = false;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sentCode = false;
        _error = 'Could not send verification code.';
      });
    }
  }

  String _deleteAuthErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-verification-code':
          return 'That code is incorrect. Check the SMS and try again.';
        case 'session-expired':
          return 'This code has expired. Tap Resend for a new code.';
        case 'invalid-credential':
          return 'That code is incorrect or no longer valid. Try again or tap Resend.';
        default:
          break;
      }
      if (e.message?.trim().isNotEmpty ?? false) {
        return e.message?.trim() ?? '';
      }
    }
    return 'Could not delete account. Please try again.';
  }

  Future<void> _confirmDeletion() async {
    if (_busy) return;
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _codeAttempted = true;
        _error = '';
      });
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
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      await widget.runDeletion(credential);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _deleteAuthErrorMessage(e);
      });
    }
  }

  InputDecoration _codeDecoration(BuildContext context, bool codeFieldError) {
    const errorRed = Color(0xFFB91C1C);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: codeFieldError
          ? const BorderSide(color: errorRed, width: 1.5)
          : BorderSide.none,
    );
    return InputDecoration(
      labelText: 'Verification code',
      labelStyle: codeFieldError
          ? const TextStyle(color: errorRed, fontWeight: FontWeight.w600)
          : null,
      floatingLabelStyle: codeFieldError
          ? const TextStyle(color: errorRed)
          : null,
      filled: true,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      enabledBorder: outline,
      focusedBorder: outline,
      disabledBorder: outline,
      border: outline,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final codeFieldError = _codeAttempted && _codeCtrl.text.trim().isEmpty;
    final fieldReadOnly = _busy || _sentCode;
    final hasCode = _verificationId != null;
    final confirmEnabled = !_busy && !_sentCode && hasCode;

    final textActionStyle = TextButton.styleFrom(
      minimumSize: const Size(0, 48),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
    final filledActionStyle = FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Delete account?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_smsStep) ...[
                Text(
                  'Are you sure?\nThis action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, height: 1.4),
                ),
              ] else ...[
                if (_sentCode)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (hasCode) ...[
                  Text(
                    'An SMS code has been sent to ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeCtrl,
                    readOnly: fieldReadOnly,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(fontSize: 18),
                    onChanged: (_) {
                      setState(() {
                        if (_error.isNotEmpty) _error = '';
                      });
                    },
                    decoration: _codeDecoration(context, codeFieldError),
                  ),
                ],
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFB91C1C),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              if (!_smsStep)
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: textActionStyle,
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: filledActionStyle.copyWith(
                          backgroundColor: const WidgetStatePropertyAll(
                            Color(0xFF3e7f3f),
                          ),
                        ),
                        onPressed: _busy ? null : _onFirstConfirm,
                        child: const Text(
                          'Proceed',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: textActionStyle,
                        onPressed: (_busy || _sentCode)
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        style: textActionStyle,
                        onPressed: (_busy || _sentCode) ? null : _sendCode,
                        child: const Text(
                          'Resend',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: filledActionStyle.copyWith(
                          backgroundColor: const WidgetStatePropertyAll(
                            Color(0xFFDD403D),
                          ),
                        ),
                        onPressed: confirmEnabled ? _confirmDeletion : null,
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
                                'Confirm',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteByPasswordDialogState extends State<_DeleteByPasswordDialog> {
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _totpCtrl;
  bool _obscure = true;
  bool _passwordAttempted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl = TextEditingController();
    _totpCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _totpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordFieldError =
        _passwordAttempted && _passwordCtrl.text.trim().isEmpty;
    const errorRed = Color(0xFFB91C1C);
    final passwordOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: passwordFieldError
          ? const BorderSide(color: errorRed, width: 1.5)
          : BorderSide.none,
    );
    final totpOutline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Delete account?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Are you sure?\nThis action cannot be undone.',
                style: TextStyle(fontSize: 18, height: 1.4),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordCtrl,
                readOnly: _busy,
                obscureText: _obscure,
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                onChanged: (_) {
                  if (_passwordAttempted) setState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: _busy
                        ? null
                        : () => setState(() => _obscure = !_obscure),
                  ),
                  labelStyle: passwordFieldError
                      ? const TextStyle(
                          color: errorRed,
                          fontWeight: FontWeight.w600,
                        )
                      : null,
                  floatingLabelStyle: passwordFieldError
                      ? const TextStyle(color: errorRed)
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  enabledBorder: passwordOutline,
                  focusedBorder: passwordOutline,
                  disabledBorder: passwordOutline,
                  border: passwordOutline,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              if (widget.emailVerified) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _totpCtrl,
                  readOnly: _busy,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Authenticator code',
                    counterText: '',
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    enabledBorder: totpOutline,
                    focusedBorder: totpOutline,
                    disabledBorder: totpOutline,
                    border: totpOutline,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
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
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDD403D),
              minimumSize: const Size(100, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _busy ? null : _submitDelete,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Delete', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDelete() async {
    if (_busy) return;
    final p = _passwordCtrl.text.trim();
    if (p.isEmpty) {
      setState(() => _passwordAttempted = true);
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.runEmailDeletion(p, _totpCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      await popupAlert(
        context,
        message: 'Could not delete account.',
        level: AppAlertLevel.error,
      );
    }
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
  late bool _allowOverBudget;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.initialAmount;
    _ctrl = TextEditingController(text: v.toStringAsFixed(0));
    _sliderVal = v.clamp(10.0, 10000.0);
    _isWeekly = widget.bp.isWeekly;
    _allowOverBudget = widget.bp.allowOverBudget;
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
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${_sign}10,000',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Over-budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 2,
                ),
              ),
              subtitle: Text(
                'Allow adding expenses that go over your budget',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
              value: _allowOverBudget,
              onChanged: (v) => setState(() => _allowOverBudget = v),
            ),
            if (_dialogError.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _dialogError,
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 18),
                textAlign: TextAlign.center,
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
          onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
          child: const Text('Cancel', style: TextStyle(fontSize: 18)),
        ),
        FilledButton(
          style: busyDialog(),
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  final v = double.tryParse(_ctrl.text.trim());
                  if (v == null || v < 10) {
                    setState(() {
                      _dialogError = 'The minimum budget is ${_sign}10.';
                      _saving = false;
                    });
                    return;
                  }
                  if (v > 10000) {
                    setState(() {
                      _dialogError = 'Max budget is ${_sign}10,000.';
                      _saving = false;
                    });
                    return;
                  }
                  try {
                    final selectedCurrencyId = _selectedCurrency?.id;
                    final userId = FirebaseAuth.instance.currentUser!.uid;
                    if (selectedCurrencyId != null) {
                      await ExampleConnector.instance
                          .updateUserCurrency(
                            userId: userId,
                            currencyId: selectedCurrencyId,
                          )
                          .execute();
                    }
                    await widget.bp.setBudget(v, isWeekly: _isWeekly);
                    await widget.bp.setAllowOverBudget(_allowOverBudget);
                    if (!context.mounted) return;
                    await Navigator.of(context).maybePop();
                  } catch (_) {
                    if (!mounted) return;
                    setState(() {
                      _dialogError = 'Could not save. Please try again.';
                      _saving = false;
                    });
                  }
                },
          child: busyButton(busy: _saving, label: 'Save Changes'),
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

class _EditProfileDialog extends StatefulWidget {
  final UserProfile profile;
  final BudgetProvider bp;

  const _EditProfileDialog({required this.profile, required this.bp});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final GlobalKey<StudentProfileFormState> _formKey =
      GlobalKey<StudentProfileFormState>();
  String _error = '';
  bool _saving = false;

  Future<void> _save() async {
    final form = _formKey.currentState!;

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
        email: user.email?.trim() ?? '',
        firstName: widget.profile.firstName,
        lastName: widget.profile.lastName,
      );

      var cmd = base
          .institutionId(selection.institutionId)
          .courseId(selection.courseId)
          .otherInstitution(selection.otherInstitution)
          .otherCourse(selection.otherCourse)
          .budget(widget.bp.budget.amount)
          .isWeekly(widget.bp.isWeekly)
          .allowOverbudget(widget.bp.allowOverBudget);
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
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              StudentProfileForm(
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
          child: const Text('Cancel', style: TextStyle(fontSize: 18)),
        ),
        FilledButton(
          style: busyDialog(),
          onPressed: _saving
              ? null
              : (_formKey.currentState?.canSubmit == true ? _save : null),
          child: busyButton(busy: _saving, label: 'Save Changes'),
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

class _SettingsPage extends StatefulWidget {
  final Future<void> Function(BuildContext context) onChangePassword;
  final Future<void> Function(BuildContext context) onMfa;
  final Future<void> Function(BuildContext context) onDeleteAccount;

  const _SettingsPage({
    required this.onChangePassword,
    required this.onMfa,
    required this.onDeleteAccount,
  });

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  Timer? _verifyEmailCooldownTimer;
  int _emailCooldown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadUser());
  }

  @override
  void dispose() {
    _verifyEmailCooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _reloadUser({bool notify = true}) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    try {
      await u.reload();
    } catch (_) {}
    if (notify && mounted) setState(() {});
  }

  void _startVerifyEmailCooldown() {
    _verifyEmailCooldownTimer?.cancel();
    setState(() => _emailCooldown = 60);
    _verifyEmailCooldownTimer = Timer.periodic(const Duration(seconds: 1), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      await _reloadUser(notify: false);
      if (!mounted) {
        t.cancel();
        return;
      }
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (verified) {
        t.cancel();
        if (mounted) {
          setState(() => _emailCooldown = 0);
        }
        return;
      }
      setState(() {
        if (_emailCooldown <= 1) {
          t.cancel();
          _emailCooldown = 0;
        } else {
          _emailCooldown--;
        }
      });
    });
  }

  String _verifyEmailSubtitle({required bool emailVerified}) {
    if (emailVerified) return 'Your email is verified';
    if (_emailCooldown > 0) {
      final s = _emailCooldown;
      return 'Resend in $s seconds';
    }
    return 'Verify your email address';
  }

  Future<void> _onVerifyEmailTap(BuildContext context) async {
    await _reloadUser();
    if (!context.mounted) return;
    final u = FirebaseAuth.instance.currentUser!;
    if (u.emailVerified) return;
    if (_emailCooldown > 0) return;
    try {
      await sendUserEmailVerification(u);
      if (!context.mounted) return;
      final email = u.email?.trim() ?? '';
      await popupAlert(
        context,
        message: 'We sent a verification email to $email.',
        level: AppAlertLevel.success,
      );
      _startVerifyEmailCooldown();
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      await popupAlert(
        context,
        message: e.message ?? 'Could not send verification email.',
        level: AppAlertLevel.error,
      );
    } catch (e) {
      if (!context.mounted) return;
      await popupAlert(context, message: '$e', level: AppAlertLevel.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final hasPassword = user.providerData.any(
      (p) => p.providerId == 'password',
    );
    final email = user.email?.trim() ?? '';
    final showVerifyEmail = email.isNotEmpty;

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
              if (hasPassword) ...[
                _SettingsTile(
                  icon: Icons.lock_outline,
                  iconColor: const Color(0xFF4ECDC4),
                  title: 'Change Password',
                  subtitle: 'Send a password reset email',
                  onTap: () => widget.onChangePassword(context),
                ),
                const SizedBox(height: 8),
              ],
              if (showVerifyEmail) ...[
                _SettingsTile(
                  icon: Icons.mark_email_unread_outlined,
                  iconColor: const Color(0xFF5C6BC0),
                  title: 'Verify Email',
                  subtitle: _verifyEmailSubtitle(
                    emailVerified: user.emailVerified,
                  ),
                  onTap: user.emailVerified
                      ? null
                      : () => _onVerifyEmailTap(context),
                ),
                const SizedBox(height: 8),
              ],
              if (hasPassword ||
                  !user.providerData.any((p) => p.providerId == 'phone')) ...[
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF3e7f3f),
                  title: 'Multi-factor Authentication',
                  subtitle: user.emailVerified
                      ? 'Enable/Disable MFA'
                      : 'Verify email to enable MFA.',
                  onTap: user.emailVerified
                      ? () => widget.onMfa(context)
                      : null,
                ),
                const SizedBox(height: 8),
              ],
              _SettingsTile(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFF87171),
                title: 'Delete Account',
                subtitle: 'Remove your account',
                onTap: () => widget.onDeleteAccount(context),
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
  final VoidCallback? onTap;
  final Widget? trailing;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      enabled: onTap != null || trailing != null,
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
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              : null),
    ),
  );
}
