import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:makecents/helper/currency_helper.dart';

import 'package:makecents/provider/budget_provider.dart';
import 'package:makecents/provider/transaction_provider.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final bp = Provider.of<BudgetProvider>(context);
    final spent = transactionProvider.periodSpent(isWeekly: bp.isWeekly);
    final label = bp.isWeekly ? 'Spent this week' : 'Spent this month';

    return Card(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatMoney(spent),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
