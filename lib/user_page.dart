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
    await showDialog<void>(
      context: context,
      builder: (_) => _ChangePasswordDialog(parentContext: context),
    );
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
          .deleteUserProfile(username: user.uid)
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

  @override
  Widget build(BuildContext context) {
    final txP = Provider.of<TransactionProvider>(context);
    final bp = Provider.of<BudgetProvider>(context);
    final tp = Provider.of<ThemeProvider>(context);
    final up = Provider.of<UserProvider>(context);
    final isDarkMode = tp.themeMode != ThemeModes.light;
    final totalSpent = txP.monthlySpent;

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
              title: 'Monthly Budget',
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

class _ChangePasswordDialog extends StatefulWidget {
  final BuildContext parentContext;

  const _ChangePasswordDialog({required this.parentContext});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final TextEditingController _newPasswordCtrl;
  late final TextEditingController _confirmPasswordCtrl;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _dialogError = '';

  @override
  void initState() {
    super.initState();
    _newPasswordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Change password'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNew,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'New password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
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
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.35,
                ),
              ),
            ),
            if (_dialogError.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _dialogError,
                style: const TextStyle(color: Colors.red, fontSize: 16),
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
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () async {
            final newPass = _newPasswordCtrl.text;
            final confirmPass = _confirmPasswordCtrl.text;
            if (newPass.isEmpty || confirmPass.isEmpty) {
              setState(() => _dialogError = 'Please fill out all fields.');
              return;
            }
            if (!passwordCriteria(newPass)) {
              setState(
                () => _dialogError = 'Password does not meet requirements.',
              );
              return;
            }
            if (newPass != confirmPass) {
              setState(() => _dialogError = 'Passwords do not match.');
              return;
            }

            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                setState(() => _dialogError = 'No active user found.');
                return;
              }
              await user.updatePassword(newPass);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (!widget.parentContext.mounted) return;
              ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                const SnackBar(content: Text('Password updated.')),
              );
            } catch (e) {
              if (!mounted) return;
              setState(() {
                _dialogError =
                    e is FirebaseAuthException &&
                        e.code == 'requires-recent-login'
                    ? 'Please log in again before changing password.'
                    : 'Could not update password.';
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
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
  String _dialogError = '';

  @override
  void initState() {
    super.initState();
    final v = widget.initialAmount;
    _ctrl = TextEditingController(text: v.toStringAsFixed(0));
    _sliderVal = v.clamp(0.0, 10000.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final val = double.tryParse(_ctrl.text.trim());
    setState(() {
      if (val != null && val >= 0 && val <= 10000) {
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        'Update Monthly Budget',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
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
              min: 0,
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
                  '${currency}0',
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
            if (v == null || v <= 0) {
              setState(() => _dialogError = 'Please enter a valid amount.');
              return;
            }
            if (v > 10000) {
              setState(() => _dialogError = 'Max budget is ${currency}10,000.');
              return;
            }
            await widget.bp.setBudget(v);
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
              _SettingsTile(
                icon: Icons.lock_outline,
                iconColor: const Color(0xFF4ECDC4),
                title: 'Change password',
                subtitle: 'Update account password',
                onTap: () => onChangePassword(context),
              ),
              const SizedBox(height: 8),
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
