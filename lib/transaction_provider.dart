import 'package:flutter/material.dart';
import 'persistence_service.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });
}

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> init() async {
    _transactions = await PersistenceService.loadTransactions();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    await PersistenceService.saveTransactions(_transactions);
  }

  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date,
  ) async {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: date,
    );
    _transactions.add(newTx);
    await _saveTransactions();
    notifyListeners();
  }
}
