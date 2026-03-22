import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';

class Budget {
  final double amount;
  const Budget({required this.amount});
}

class BudgetProvider with ChangeNotifier {
  Budget _budget = Budget(amount: 0.0);

  Budget get budget => _budget;

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final result = await ExampleConnector.instance
          .getUserProfile(username: user.uid)
          .execute();
      if (result.data.users.isNotEmpty) {
        final dbBudget = result.data.users.first.monthlyBudget;
        if (dbBudget != null) {
          _budget = Budget(amount: dbBudget);
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setBudget(double amount) async {
    if (amount <= 0 || amount > 10000) return;

    _budget = Budget(amount: amount);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await ExampleConnector.instance
          .updateUserBudget(username: user.uid, budget: amount)
          .execute();
    } catch (_) {}
  }
}
