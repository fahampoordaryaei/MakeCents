import 'package:flutter/foundation.dart';
import 'package:makecents/dataconnect_generated/generated.dart';

class CategoryBudgetRow {
  CategoryBudgetRow({
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
  });
  final String categoryId;
  final String categoryName;
  final int budgetAmount;
}

class CategoryBudgetProvider extends ChangeNotifier {
  List<CategoryBudgetRow> budgets = [];

  Future<void> load(String userId) async {
    final r = await ExampleConnector.instance
        .listUserCategoryBudgets(userId: userId)
        .execute();
    budgets = [
      for (final row in r.data.categoryBudgets)
        CategoryBudgetRow(
          categoryId: row.category.id,
          categoryName: row.category.name,
          budgetAmount: row.budgetAmount,
        ),
    ];
    notifyListeners();
  }

  Future<void> upsert(
    String userId,
    String categoryId,
    int budgetAmount,
  ) async {
    await ExampleConnector.instance
        .upsertCategoryBudget(
          userId: userId,
          categoryId: categoryId,
          budgetAmount: budgetAmount,
        )
        .execute();
    await load(userId);
  }

  Future<void> delete(String userId, String categoryId) async {
    await ExampleConnector.instance
        .deleteCategoryBudget(userId: userId, categoryId: categoryId)
        .execute();
    await load(userId);
  }
}
