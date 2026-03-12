import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'dataconnect_generated/generated.dart';

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
  bool isLoading = false;

  Future<void> init() async {
    await fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      _transactions = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final query = ExampleConnector.instance.listUserTransactions(
        userId: user.uid,
      );
      final response = await query.execute();

      _transactions = response.data.transactions
          .map(
            (t) => Transaction(
              id: t.id,
              title: t.description ?? t.category,
              amount: t.amount,
              date: t.date,
              category: t.category,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date, {
    String category = 'Other',
  }) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Optimistic UI update
    final tempId = DateTime.now().toString();
    _transactions.insert(
      0,
      Transaction(
        id: tempId,
        title: title,
        amount: amount,
        date: date,
        category: category,
      ),
    );
    notifyListeners();

    try {
      final mutation = ExampleConnector.instance
          .addTransaction(
            userId: user.uid,
            category: category,
            amount: amount,
            date: date,
          )
          .description(title);

      await mutation.execute();
      // Only refetch if we need the real DB ID immediately, otherwise optimistic update holds
      await fetchTransactions();
    } catch (e) {
      debugPrint("Error adding transaction: $e");
      // Revert optimistic update on failure
      _transactions.removeWhere((t) => t.id == tempId);
      notifyListeners();
    }
  }

  Future<void> removeTransaction(int index) async {
    if (index < 0 || index >= _transactions.length) return;

    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final removedTx = _transactions[index];
    final removedId = removedTx.id;

    // Optimistic UI update
    _transactions.removeAt(index);
    notifyListeners();

    try {
      await ExampleConnector.instance
          .deleteTransaction(id: removedId)
          .execute();
      debugPrint("Successfully deleted transaction: $removedId");
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
      // Revert optimistic update
      _transactions.insert(index, removedTx);
      notifyListeners();
      rethrow;
    }
  }
}
