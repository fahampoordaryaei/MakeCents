import 'package:flutter/material.dart';
import 'persistence_service.dart';

class Budget {
  final double amount;

  Budget({required this.amount});
}

class BudgetProvider with ChangeNotifier {
  Budget _budget = Budget(amount: 0.0);

  Budget get budget => _budget;

  Future<void> init() async {
    _budget = await PersistenceService.loadBudget();
    notifyListeners();
  }

  Future<void> _saveBudget() async {
    await PersistenceService.saveBudget(_budget);
  }

  Future<void> setBudget(double amount) async {
    _budget = Budget(amount: amount);
    await _saveBudget();
    notifyListeners();
  }
}
