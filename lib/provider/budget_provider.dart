import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/helper/currency_helper.dart';
import 'package:makecents/provider/category_provider.dart';

class Budget {
  final double amount;
  final bool isWeekly;
  const Budget({required this.amount, this.isWeekly = false});
}

class BudgetProvider with ChangeNotifier {
  Budget _budget = const Budget(amount: 0.0);
  bool _allowOverBudget = true;

  Budget get budget => _budget;
  bool get isWeekly => _budget.isWeekly;
  String get periodLabel => _budget.isWeekly ? 'Weekly' : 'Monthly';
  bool get allowOverBudget => _allowOverBudget;

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      await Future.wait([
        () async {
          final result = await ExampleConnector.instance
              .getUserProfile(userId: user.uid)
              .execute();
          if (result.data.users.isNotEmpty) {
            final u = result.data.users.first;
            _budget = Budget(amount: u.budget ?? 0.0, isWeekly: u.isWeekly);
            _allowOverBudget = u.allowOverbudget;
            if (u.currency != null) {
              setGlobalCurrency(sign: u.currency!.sign, id: u.currency!.id);
            }
          }
        }(),
        () async {
          try {
            final cats = await ExampleConnector.instance
                .listCategories()
                .execute();
            setCategories(cats.data.categories);
          } catch (_) {}
        }(),
      ]);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setAllowOverBudget(bool value) async {
    final user = FirebaseAuth.instance.currentUser!;

    _allowOverBudget = value;
    notifyListeners();

    try {
      await ExampleConnector.instance
          .updateUserAllowOverbudget(userId: user.uid, allowOverbudget: value)
          .execute();
    } catch (_) {
      await init();
      rethrow;
    }
  }

  Future<void> setBudget(double amount, {bool? isWeekly}) async {
    if (amount <= 0 || amount > 10000) return;

    _budget = Budget(amount: amount, isWeekly: isWeekly ?? _budget.isWeekly);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser!;

    try {
      final req = ExampleConnector.instance.updateUserBudget(
        userId: user.uid,
        budget: amount,
      );
      if (isWeekly != null) {
        req.isWeekly(isWeekly);
      }
      await req.execute();
    } catch (_) {}
  }
}
