import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
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
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get monthlySpent {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchTransactions() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      _transactions = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final query = ExampleConnector.instance.listUserTransactions(
        userId: user.uid,
      );
      final response = await query.execute();

      _transactions = response.data.transactions.map((tx) {
        final catName = tx.category.name;
        return Transaction(
          id: tx.id,
          title: tx.description ?? 'Expense',
          amount: tx.amount,
          date: tx.date,
          category: catName,
        );
      }).toList();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date, {
    String categoryName = 'Other',
    required String categoryId,
  }) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tempId = DateTime.now().toString();
    _transactions.insert(
      0,
      Transaction(
        id: tempId,
        title: title,
        amount: amount,
        date: date,
        category: categoryName,
      ),
    );
    notifyListeners();

    try {
      final mutation = ExampleConnector.instance
          .addTransaction(
            userId: user.uid,
            categoryId: categoryId,
            amount: amount,
            date: date,
          )
          .description(title);

      await mutation.execute();
    } catch (_) {
      _transactions.removeWhere((t) => t.id == tempId);
      notifyListeners();
      rethrow;
    }

    try {
      final pointsResult = await ExampleConnector.instance
          .getUserPoints(userId: user.uid)
          .execute();

      if (pointsResult.data.pointsBalances.isNotEmpty) {
        final existing = pointsResult.data.pointsBalances.first;
        await ExampleConnector.instance
            .updatePointsBalance(
              id: existing.id,
              totalPoints: existing.totalPoints + 10,
            )
            .execute();
      }
    } catch (_) {}

    await fetchTransactions();
  }

  Future<void> removeTransaction(int index) async {
    if (index < 0 || index >= _transactions.length) return;

    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final removedTx = _transactions[index];

    _transactions.removeAt(index);
    notifyListeners();

    try {
      await ExampleConnector.instance
          .deleteTransaction(id: removedTx.id)
          .execute();
    } catch (_) {
      _transactions.insert(index, removedTx);
      notifyListeners();
      rethrow;
    }

    try {
      final pointsResult = await ExampleConnector.instance
          .getUserPoints(userId: user.uid)
          .execute();

      if (pointsResult.data.pointsBalances.isNotEmpty) {
        final existing = pointsResult.data.pointsBalances.first;
        final next = existing.totalPoints - 10;
        await ExampleConnector.instance
            .updatePointsBalance(
              id: existing.id,
              totalPoints: next < 0 ? 0 : next,
            )
            .execute();
      }
    } catch (_) {}
  }

  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
    required String categoryName,
  }) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index < 0) return;

    final original = _transactions[index];
    final updated = Transaction(
      id: original.id,
      title: title,
      amount: amount,
      date: date,
      category: categoryName,
    );

    _transactions[index] = updated;
    notifyListeners();

    try {
      final mutation = ExampleConnector.instance
          .updateTransaction(
            id: id,
            categoryId: categoryId,
            amount: amount,
            date: date,
          )
          .description(title);
      await mutation.execute();
      await fetchTransactions();
    } catch (_) {
      _transactions[index] = original;
      notifyListeners();
      rethrow;
    }
  }
}
