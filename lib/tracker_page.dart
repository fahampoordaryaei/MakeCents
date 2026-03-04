// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final TextEditingController _amountController = TextEditingController();

  bool _showOverBudgetWarning = true;

  Future<void> _submitData() async {
    final String input = _amountController.text;
    if (input.isEmpty) return;
    final double? amount = double.tryParse(input);
    if (amount == null || amount <= 0) return;

    final budgetAmount = Provider.of<BudgetProvider>(
      context,
      listen: false,
    ).budget.amount;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final currentExpenses = txProvider.transactions.fold(
      0.0,
      (sum, tx) => sum + tx.amount,
    );

    if (_showOverBudgetWarning && (currentExpenses + amount > budgetAmount)) {
      await _showOverBudgetDialog(amount, budgetAmount, currentExpenses);
    } else {
      await txProvider.addTransaction('Expense', amount, DateTime.now());
      _amountController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added expense: \$${amount.toStringAsFixed(2)}'),
        ),
      );
    }
  }

  Future<void> _showOverBudgetDialog(
    double amount,
    double budget,
    double currentExpenses,
  ) async {
    bool dontShowAgain = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Over Budget Warning"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Adding this expense will exceed your budget by \$${(currentExpenses + amount - budget).toStringAsFixed(2)}. Continue?",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: dontShowAgain,
                        onChanged: (val) {
                          setState(() {
                            dontShowAgain = val ?? false;
                          });
                        },
                      ),
                      const Text("Don't show again"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () async {
                    if (dontShowAgain) {
                      setState(() {
                        _showOverBudgetWarning = false;
                      });
                    }
                    Navigator.of(context).pop();
                    final txProvider = Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    );
                    await txProvider.addTransaction(
                      'Expense',
                      amount,
                      DateTime.now(),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added expense: \$${amount.toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  },
                  child: const Text("Add Anyway"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetAmount = Provider.of<BudgetProvider>(context).budget.amount;
    final txProvider = Provider.of<TransactionProvider>(context);
    final expenses = txProvider.transactions.fold(
      0.0,
      (sum, tx) => sum + tx.amount,
    );
    final available = (budgetAmount - expenses) > 0
        ? (budgetAmount - expenses)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page title (same style as Home)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Tracker',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
          ),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Add New Expense",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Amount',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _submitData,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Financial Breakdown",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (budgetAmount > 0 && expenses > budgetAmount)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "You are \$${(expenses - budgetAmount).toStringAsFixed(2)} over budget",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: budgetAmount <= 0
                    ? [
                        PieChartSectionData(
                          color: Colors.grey.shade300,
                          value: 100,
                          title: "",
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ]
                    : [
                        PieChartSectionData(
                          color: Colors.green,
                          value: available,
                          title: available.toStringAsFixed(0),
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.redAccent,
                          value: expenses,
                          title: expenses.toStringAsFixed(0),
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, "Available"),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.redAccent, "Expenses"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
