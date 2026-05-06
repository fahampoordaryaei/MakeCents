import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';

class CategoryBudget {
  final String categoryId;
  final String categoryName;
  final String? iconName;
  final String? colorHex;
  final int budgetAmount;

  CategoryBudget({
    required this.categoryId,
    required this.categoryName,
    this.iconName,
    this.colorHex,
    required this.budgetAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'iconName': iconName,
      'colorHex': colorHex,
      'budgetAmount': budgetAmount,
    };
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      iconName: json['iconName'],
      colorHex: json['colorHex'],
      budgetAmount: json['budgetAmount'],
    );
  }
}

class MockExpenseCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;

  MockExpenseCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });
}

class CategoryBudgetPage extends StatefulWidget {
  const CategoryBudgetPage({super.key});

  @override
  State<CategoryBudgetPage> createState() => _CategoryBudgetPageState();
}

class _CategoryBudgetPageState extends State<CategoryBudgetPage> {
  List<CategoryBudget> _categoryBudgets = [];
  List<MockExpenseCategory> _availableCategories = [];
  bool _isLoading = true;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _prefs = await SharedPreferences.getInstance();
      await Future.wait([_loadCategoryBudgets(), _loadAvailableCategories()]);
    } catch (e) {
      if (mounted) {
        await popupAlert(
          context,
          message: 'Error loading data: $e',
          level: AppAlertLevel.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategoryBudgets() async {
    final budgetsJson = _prefs.getString('category_budgets');
    if (budgetsJson != null) {
      final List<dynamic> data = jsonDecode(budgetsJson);
      _categoryBudgets = data
          .map((item) => CategoryBudget.fromJson(item))
          .toList();
    }
  }

  Future<void> _loadAvailableCategories() async {
    try {
      final query = ExampleConnector.instance.listExpenseCategories();
      final response = await query.execute();
      _availableCategories = response.data.expenseCategories.map((cat) {
        return MockExpenseCategory(
          id: cat.id,
          name: cat.name,
          iconName: cat.iconName,
          colorHex: cat.colorHex,
        );
      }).toList();
    } catch (_) {
      _availableCategories = [];
    }
  }

  Future<void> _setBudget(
    String categoryId,
    String categoryName,
    int amount,
  ) async {
    try {
      final existingIndex = _categoryBudgets.indexWhere(
        (cb) => cb.categoryId == categoryId,
      );
      final category = _availableCategories.firstWhere(
        (c) => c.id == categoryId,
      );

      if (existingIndex >= 0) {
        _categoryBudgets[existingIndex] = CategoryBudget(
          categoryId: categoryId,
          categoryName: categoryName,
          iconName: category.iconName,
          colorHex: category.colorHex,
          budgetAmount: amount,
        );
      } else {
        _categoryBudgets.add(
          CategoryBudget(
            categoryId: categoryId,
            categoryName: categoryName,
            iconName: category.iconName,
            colorHex: category.colorHex,
            budgetAmount: amount,
          ),
        );
      }

      final budgetsJson = jsonEncode(
        _categoryBudgets.map((b) => b.toJson()).toList(),
      );
      await _prefs.setString('category_budgets', budgetsJson);

      setState(() {});

      if (mounted) {
        await popupAlert(
          context,
          message: 'Budget updated successfully',
          level: AppAlertLevel.success,
        );
      }
    } catch (e) {
      if (mounted) {
        await popupAlert(
          context,
          message: 'Error updating budget: $e',
          level: AppAlertLevel.error,
        );
      }
    }
  }

  Future<void> _deleteBudget(String categoryId) async {
    try {
      _categoryBudgets.removeWhere((cb) => cb.categoryId == categoryId);
      final budgetsJson = jsonEncode(
        _categoryBudgets.map((b) => b.toJson()).toList(),
      );
      await _prefs.setString('category_budgets', budgetsJson);

      setState(() {});

      if (mounted) {
        await popupAlert(
          context,
          message: 'Budget deleted successfully',
          level: AppAlertLevel.success,
        );
      }
    } catch (e) {
      if (mounted) {
        await popupAlert(
          context,
          message: 'Error deleting budget: $e',
          level: AppAlertLevel.error,
        );
      }
    }
  }

  void _showBudgetDialog(
    CategoryBudget? existingBudget,
    MockExpenseCategory category,
  ) {
    final controller = TextEditingController(
      text: existingBudget?.budgetAmount.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '\$',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                _setBudget(category.id, category.name, amount);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category Budgets')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Category Budgets')),
      body: _availableCategories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load expense categories. Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                    fontSize: 18,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableCategories.length,
              itemBuilder: (context, index) {
                final category = _availableCategories[index];
                final existingBudget = _categoryBudgets
                    .where((cb) => cb.categoryId == category.id)
                    .firstOrNull;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: parseColorHex(category.colorHex),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        getIconByName(category.iconName),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: existingBudget != null
                        ? Text(
                            'Budget: ${formatMoney(existingBudget.budgetAmount.toDouble())}',
                          )
                        : const Text('No budget set'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showBudgetDialog(existingBudget, category),
                        ),
                        if (existingBudget != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteBudget(category.id),
                          ),
                      ],
                    ),
                    onTap: () => _showBudgetDialog(existingBudget, category),
                  ),
                );
              },
            ),
    );
  }
}
