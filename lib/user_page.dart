import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'budget_provider.dart';
import 'transaction_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme_provider.dart';
import 'user_provider.dart';

class UserPage extends StatelessWidget {
  final VoidCallback onNavigateToBudget;
  const UserPage({super.key, required this.onNavigateToBudget});

  Future<void> _editBudgetDialog(BuildContext context) async {
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final initialValue = bp.budget.amount;
    final ctrl = TextEditingController(text: initialValue.toStringAsFixed(0));
    double sliderVal = initialValue.clamp(0.0, 10000.0);
    String dialogError = '';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void onTextChanged() {
            final val = double.tryParse(ctrl.text.trim());
            if (val != null && val >= 0 && val <= 10000) {
              if (sliderVal != val) {
                setDialogState(() => sliderVal = val);
              }
            } else if (val != null && val > 10000) {
              setDialogState(() => sliderVal = 10000);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'Update Monthly Budget',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dialogError.isNotEmpty) ...[
                  Text(
                    dialogError,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (_) => onTextChanged(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    prefixText: '€',
                    prefixStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
                    value: sliderVal,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    onChanged: (v) {
                      setDialogState(() {
                        sliderVal = v;
                        ctrl.text = v.toInt().toString();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '€0',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '€10k',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3e7f3f),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final v = double.tryParse(ctrl.text.trim());
                  if (v == null || v <= 0) {
                    setDialogState(
                      () => dialogError = 'Please enter a valid amount.',
                    );
                    return;
                  }
                  if (v > 10000) {
                    setDialogState(
                      () => dialogError = 'Max budget is €10,000.',
                    );
                    return;
                  }
                  await bp.setBudget(v);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txP = Provider.of<TransactionProvider>(context);
    final bp = Provider.of<BudgetProvider>(context);
    final tp = Provider.of<ThemeProvider>(context);
    final up = Provider.of<UserProvider>(context);
    final isDarkMode = tp.themeType != ThemeType.light;
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
                      fontSize: 24,
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
                  if (up.profile?.school != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3e7f3f).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        up.profile!.school!,
                        style: const TextStyle(
                          color: Color(0xFF3e7f3f),
                          fontSize: 12,
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
                    '€${totalSpent.toStringAsFixed(2)}',
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
            const SizedBox(height: 28),

            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF3e7f3f),
              title: 'Monthly Budget',
              subtitle: '€${bp.budget.amount.toStringAsFixed(2)}',
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
                  tp.setTheme(val ? ThemeType.darkNavy : ThemeType.light);
                },
                activeThumbColor: const Color(0xFF3e7f3f),
              ),
              onTap: () {
                tp.setTheme(isDarkMode ? ThemeType.light : ThemeType.darkNavy);
              },
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
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
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
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  );
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
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
    ),
  );
}
