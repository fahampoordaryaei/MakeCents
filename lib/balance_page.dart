import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'transaction_provider.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    final totalBalance = transactions.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Current Balance', style: TextStyle(fontSize: 20)),
            Text(
              '\$${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
