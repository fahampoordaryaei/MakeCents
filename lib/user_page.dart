// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'budget_provider.dart';

class UserPage extends StatelessWidget {
  final VoidCallback onNavigateToBudget;

  const UserPage({super.key, required this.onNavigateToBudget});

  void _showDebugMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Debug Menu'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Login Page'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editBudgetDialog(BuildContext context) async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final controller = TextEditingController(
      text: budgetProvider.budget.amount.toStringAsFixed(0),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Monthly Budget'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monthly Budget'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final val = double.tryParse(controller.text);
                if (val != null) {
                  await budgetProvider.setBudget(val);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
                if (kDebugMode)
                  IconButton(
                    icon: const Icon(Icons.bug_report),
                    onPressed: () => _showDebugMenu(context),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<BudgetProvider>(
              builder: (context, budgetProvider, child) {
                final amount = budgetProvider.budget.amount;
                return Card(
                  child: ListTile(
                    title: const Text('Monthly Budget'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBudgetDialog(context),
                        ),
                      ],
                    ),
                    onTap: () => _editBudgetDialog(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
