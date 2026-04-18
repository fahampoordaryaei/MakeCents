import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'functions.dart';
import 'transaction_provider.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});
  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BudgetProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final spent = txProvider.monthlySpent;
    final budget = bp.budget.amount;
    final left = (budget - spent).clamp(0.0, double.infinity);
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Monthly Budget',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3e7f3f), Color(0xFF6abf69)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3e7f3f).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Budget',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    budget > 0 ? formatMoney(budget) : 'Not set',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _BudgetStat(
                          'Spent',
                          formatMoney(spent),
                          Colors.white,
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Expanded(
                        child: _BudgetStat(
                          'Remaining',
                          formatMoney(left),
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (budget > 0) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}% used',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BudgetStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      Text(
        label,
        style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 16),
      ),
    ],
  );
}
