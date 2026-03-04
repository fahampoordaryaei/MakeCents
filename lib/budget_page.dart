import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  void _showSetBudgetDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Set'),
            onPressed: () {
              final amount = double.parse(amountController.text);

              if (amount > 0) {
                Provider.of<BudgetProvider>(
                  context,
                  listen: false,
                ).setBudget(amount);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final budget = budgetProvider.budget;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budget')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Monthly Budget:', style: TextStyle(fontSize: 24)),
            Text(
              '\$${budget.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSetBudgetDialog(context),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
