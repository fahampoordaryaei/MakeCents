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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
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
      // Try to load from backend first
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
    } catch (e) {
      // Fall back to mock categories if backend fails
      _availableCategories = [
        MockExpenseCategory(
          id: '1',
          name: 'Food',
          iconName: 'restaurant',
          colorHex: '#FF6B6B',
        ),
        MockExpenseCategory(
          id: '2',
          name: 'Transportation',
          iconName: 'directions_car',
          colorHex: '#4ECDC4',
        ),
        MockExpenseCategory(
          id: '3',
          name: 'Entertainment',
          iconName: 'movie',
          colorHex: '#45B7D1',
        ),
        MockExpenseCategory(
          id: '4',
          name: 'Shopping',
          iconName: 'shopping_cart',
          colorHex: '#96CEB4',
        ),
        MockExpenseCategory(
          id: '5',
          name: 'Bills',
          iconName: 'receipt',
          colorHex: '#FFEAA7',
        ),
        MockExpenseCategory(
          id: '6',
          name: 'Healthcare',
          iconName: 'local_hospital',
          colorHex: '#DDA0DD',
        ),
        MockExpenseCategory(
          id: '7',
          name: 'Education',
          iconName: 'school',
          colorHex: '#98D8C8',
        ),
        MockExpenseCategory(
          id: '8',
          name: 'Travel',
          iconName: 'flight',
          colorHex: '#F7DC6F',
        ),
        MockExpenseCategory(
          id: '9',
          name: 'Other',
          iconName: 'category',
          colorHex: '#BB8FCE',
        ),
      ];
    }
  }

  Future<void> _setBudget(
    String categoryId,
    String categoryName,
    int amount,
  ) async {
    try {
      // Update local state
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

      // Save to local storage
      final budgetsJson = jsonEncode(
        _categoryBudgets.map((b) => b.toJson()).toList(),
      );
      await _prefs.setString('category_budgets', budgetsJson);

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating budget: $e')));
      }
    }
  }

  Future<void> _deleteBudget(String categoryId) async {
    try {
      // Update local state
      _categoryBudgets.removeWhere((cb) => cb.categoryId == categoryId);

      // Save to local storage
      final budgetsJson = jsonEncode(
        _categoryBudgets.map((b) => b.toJson()).toList(),
      );
      await _prefs.setString('category_budgets', budgetsJson);

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting budget: $e')));
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
      body: ListView.builder(
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
                  color: _getCategoryColor(category.name),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category.iconName),
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

  Color _getCategoryColor(String categoryName) {
    final colorMap = {
      'Food': Colors.blue,
      'Transportation': Colors.green,
      'Entertainment': Colors.orange,
      'Shopping': Colors.purple,
      'Bills': Colors.red,
      'Healthcare': Colors.pink,
      'Education': Colors.teal,
      'Travel': Colors.indigo,
      'Other': Colors.grey,
    };

    return colorMap[categoryName] ??
        Colors.primaries[categoryName.hashCode % Colors.primaries.length];
  }

  IconData _getCategoryIcon(String? iconName) {
    // Map icon names to Flutter icons
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'shopping_cart': Icons.shopping_cart,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'flight': Icons.flight,
    };

    return iconMap[iconName] ?? Icons.category;
  }
}
