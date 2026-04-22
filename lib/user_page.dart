import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';
import 'login_page.dart';
import 'theme_provider.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';

class UserPage extends StatelessWidget {
  final VoidCallback onNavigateToBudget;
  const UserPage({super.key, required this.onNavigateToBudget});

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
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
          style: const TextStyle(fontSize: 16),
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
    } catch (e) {
      debugPrint('user: sendPasswordResetEmail unexpected error: $e');
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
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountPasswordDialog(),
    );

    if (!context.mounted) return;
    if (password == null || password.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No active user found.')));
        return;
      }

      final email = user.email;
      if (email == null || email.isEmpty) return;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
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
    } catch (e) {
      debugPrint('user_page: deleteAccount failed: $e');
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

  @override
  Widget build(BuildContext context) {
    final txP = Provider.of<TransactionProvider>(context);
    final bp = Provider.of<BudgetProvider>(context);
    final tp = Provider.of<ThemeProvider>(context);
    final up = Provider.of<UserProvider>(context);
    final isDarkMode = tp.themeMode != ThemeModes.light;
    final totalSpent = txP.periodSpent(isWeekly: bp.isWeekly);

    final user = FirebaseAuth.instance.currentUser;
    final userEmail = up.profile?.email ?? user?.email ?? '';
    final userName = up.profile?.fullName ?? user?.displayName ?? '';

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
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
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
                          fontSize: 16,
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
                    'Transactions',
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),

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
  String _dialogError = '';

  @override
  void initState() {
    super.initState();
    final v = widget.initialAmount;
    _ctrl = TextEditingController(text: v.toStringAsFixed(0));
    _sliderVal = v.clamp(10.0, 10000.0);
    _isWeekly = widget.bp.isWeekly;
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

  @override
  Widget build(BuildContext context) {
    final periodWord = _isWeekly ? 'Weekly' : 'Monthly';
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        'Update $periodWord Budget',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_dialogError.isNotEmpty) ...[
            Text(
              _dialogError,
              style: const TextStyle(color: Colors.red, fontSize: 16),
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
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF3e7f3f);
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            onChanged: (_) => _onTextChanged(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              prefixText: currency,
              prefixStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
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
                  '${currency}10',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${currency}10k',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                    fontSize: 16,
                  ),
                ),
              ],
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
                () => _dialogError = 'The minimum budget is ${currency}10.',
              );
              return;
            }
            if (v > 10000) {
              setState(() => _dialogError = 'Max budget is ${currency}10,000.');
              return;
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
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
              if (FirebaseAuth.instance.currentUser?.providerData.any(
                    (p) => p.providerId == 'password',
                  ) ??
                  false) ...[
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
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
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
