import 'transaction_provider.dart';
import 'budget_provider.dart';

class PersistenceService {
  static const _transactionsKey = 'transactions';
  static const _budgetKey = 'budget';

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    return;
  }

  static Future<List<Transaction>> loadTransactions() async {
    return <Transaction>[];
  }

  static Future<void> saveBudget(Budget budget) async {
    return;
  }

  static Future<Budget> loadBudget() async {
    // Hardcoded $1000 Budget
    return Budget(amount: 1000.0);
  }

  static Future<void> clearAll() async {
    return;
  }
}
