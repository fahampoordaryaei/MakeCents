import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';

class Budget {
  final double amount;
  final bool isWeekly;
  const Budget({required this.amount, this.isWeekly = false});

  Budget copyWith({double? amount, bool? isWeekly}) => Budget(
    amount: amount ?? this.amount,
    isWeekly: isWeekly ?? this.isWeekly,
  );
}

class BudgetProvider with ChangeNotifier {
  Budget _budget = const Budget(amount: 0.0);

  Budget get budget => _budget;
  bool get isWeekly => _budget.isWeekly;
  String get periodLabel => _budget.isWeekly ? 'Weekly' : 'Monthly';

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final result = await ExampleConnector.instance
          .getUserProfile(userId: user.uid)
          .execute();
      if (result.data.users.isNotEmpty) {
        final u = result.data.users.first;
        _budget = Budget(amount: u.budget ?? 0.0, isWeekly: u.isWeekly);
        if (u.currency != null) {
          setGlobalCurrency(sign: u.currency!.sign, id: u.currency!.id);
        }
      }
    } catch (e) {
      debugPrint('budget_provider: init failed: $e');
    }
    notifyListeners();
  }

  Future<void> setBudget(double amount, {bool? isWeekly}) async {
    if (amount <= 0 || amount > 10000) return;

    _budget = _budget.copyWith(amount: amount, isWeekly: isWeekly);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final req = ExampleConnector.instance.updateUserBudget(
        userId: user.uid,
        budget: amount,
      );
      if (isWeekly != null) {
        req.isWeekly(isWeekly);
      }
      await req.execute();
    } catch (e) {
      debugPrint('budget_provider: setBudget failed: $e');
    }
  }
}
