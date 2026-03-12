import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dataconnect_generated/generated.dart';
import 'persistence_service.dart';

class Budget {
  final double amount;

  Budget({required this.amount});
}

class BudgetProvider with ChangeNotifier {
  Budget _budget = Budget(amount: 0.0);

  Budget get budget => _budget;

  Future<void> init() async {
    // 1. Try local cache first
    _budget = await PersistenceService.loadBudget();

    // 2. Try fetching from Data Connect if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final connector = ExampleConnector.instance;
        final result = await connector
            .getUserProfile(username: user.uid)
            .execute();
        if (result.data.users.isNotEmpty) {
          final dbBudget = result.data.users.first.monthlyBudget;
          if (dbBudget != null) {
            _budget = Budget(amount: dbBudget);
            await PersistenceService.saveBudget(_budget);
          }
        }
      } catch (e) {
        debugPrint('Error syncing budget with backend: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveBudget() async {
    await PersistenceService.saveBudget(_budget);
  }

  Future<void> setBudget(double amount) async {
    _budget = Budget(amount: amount);
    await _saveBudget();

    // Sync to backend if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final names = (user.displayName ?? '').split(' ');
        final firstName = names.isNotEmpty ? names[0] : 'User';
        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

        await ExampleConnector.instance
            .storeUserProfile(
              username: user.uid,
              email: user.email ?? '',
              firstName: firstName,
              lastName: lastName,
            )
            .monthlyBudget(amount)
            .execute();
      } catch (e) {
        debugPrint('Error saving budget to backend: $e');
      }
    }

    notifyListeners();
  }
}
