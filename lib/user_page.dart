// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'budget_provider.dart';
import 'transaction_provider.dart';

class UserPage extends StatelessWidget {
  final VoidCallback onNavigateToBudget;
  const UserPage({super.key, required this.onNavigateToBudget});

  Future<void> _editBudgetDialog(BuildContext context) async {
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final ctrl = TextEditingController(text: bp.budget.amount.toStringAsFixed(0));
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Edit Monthly Budget'),
      content: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Monthly Budget (\$)',
          filled: true, fillColor: const Color(0xFFF4F7F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3e7f3f)),
          onPressed: () async {
            final v = double.tryParse(ctrl.text);
            if (v != null) await bp.setBudget(v);
            Navigator.pop(ctx);
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final txs = Provider.of<TransactionProvider>(context).transactions;
    final bp  = Provider.of<BudgetProvider>(context);
    final totalSpent = txs.fold(0.0, (s, t) => s + t.amount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            if (kDebugMode)
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                onPressed: () => showDialog(context: context, builder: (_) => SimpleDialog(
                  title: const Text('Debug'),
                  children: [SimpleDialogOption(
                    onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())); },
                    child: const Text('Login Page'),
                  )],
                )),
              ),
          ]),
          const SizedBox(height: 24),

          // Avatar + name
          Center(child: Column(children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3e7f3f), Color(0xFF6abf69)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF3e7f3f).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 12),
            const Text('Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const Text('admin@example.com', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ])),
          const SizedBox(height: 28),

          // Stats row
          Row(children: [
            Expanded(child: _StatCard('Total Spent', '\$${totalSpent.toStringAsFixed(2)}', Icons.arrow_upward_rounded, const Color(0xFFFF6B6B))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Transactions', '${txs.length}', Icons.receipt_long_outlined, const Color(0xFF4ECDC4))),
          ]),
          const SizedBox(height: 28),

          // Settings section
          const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFF3e7f3f),
            title: 'Monthly Budget',
            subtitle: '\$${bp.budget.amount.toStringAsFixed(2)}',
            onTap: () => _editBudgetDialog(context),
            trailing: IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _editBudgetDialog(context)),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFAA96DA),
            title: 'Notifications',
            subtitle: 'Manage alerts',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF4ECDC4),
            title: 'Security',
            subtitle: 'Password & 2FA',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout_outlined,
            iconColor: const Color(0xFFFF6B6B),
            title: 'Log Out',
            subtitle: 'Sign out of your account',
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false),
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1A2E))),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ]),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      onTap: onTap,
      leading: Container(width: 40, height: 40,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
    ),
  );
}
