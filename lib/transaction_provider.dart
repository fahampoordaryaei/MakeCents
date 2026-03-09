import 'package:flutter/material.dart';
import 'persistence_service.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = 'Other',
  });
}

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Future<void> init() async {
    _transactions = await PersistenceService.loadTransactions();
    notifyListeners();
  }

  Future<void> _save() async => PersistenceService.saveTransactions(_transactions);

  Future<void> addTransaction(String title, double amount, DateTime date, {String category = 'Other'}) async {
    _transactions.add(Transaction(id: DateTime.now().toString(), title: title, amount: amount, date: date, category: category));
    await _save();
    notifyListeners();
  }

  Future<void> removeTransaction(int index) async {
    if (index < 0 || index >= _transactions.length) return;
    _transactions.removeAt(index);
    await _save();
    notifyListeners();
  }
}
