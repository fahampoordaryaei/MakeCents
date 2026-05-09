import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/helper/ui_helper.dart';
import 'package:makecents/helper/currency_helper.dart';
import 'package:makecents/provider/category_provider.dart';

import 'package:makecents/provider/category_budget_provider.dart';
import 'package:makecents/widget/busy_button.dart';

class MockCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;

  MockCategory({
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
  List<MockCategory> _availableCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      if (mounted) {
        await context.read<CategoryBudgetProvider>().load(uid);
      }
      await _loadAvailableCategories();
    } catch (_) {
      if (mounted) {
        await popupAlert(
          context,
          message: 'Could not load data. Check your connection and try again.',
          level: AppAlertLevel.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAvailableCategories() async {
    try {
      final query = ExampleConnector.instance.listCategories();
      final response = await query.execute();
      _availableCategories = response.data.categories.map((cat) {
        return MockCategory(
          id: cat.id,
          name: cat.name,
          iconName: cat.iconName,
          colorHex: cat.colorHex,
        );
      }).toList();
      _availableCategories.sort((a, b) {
        final aOther = a.name.toLowerCase() == 'other';
        final bOther = b.name.toLowerCase() == 'other';
        if (aOther == bOther) return 0;
        return aOther ? 1 : -1;
      });
    } catch (_) {
      _availableCategories = [];
    }
  }

  Future<void> _setBudget(String categoryId, int amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await context.read<CategoryBudgetProvider>().upsert(
        uid,
        categoryId,
        amount,
      );
      if (mounted) {
        await popupAlert(
          context,
          message: 'Budget updated successfully',
          level: AppAlertLevel.success,
        );
      }
    } catch (_) {
      if (mounted) {
        await popupAlert(
          context,
          message: 'Could not update budget. Try again.',
          level: AppAlertLevel.error,
        );
      }
    }
  }

  Future<void> _deleteBudget(String categoryId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await context.read<CategoryBudgetProvider>().delete(uid, categoryId);
      if (mounted) {
        await popupAlert(
          context,
          message: 'Budget deleted successfully',
          level: AppAlertLevel.success,
        );
      }
    } catch (_) {
      if (mounted) {
        await popupAlert(
          context,
          message: 'Could not delete budget. Try again.',
          level: AppAlertLevel.error,
        );
      }
    }
  }

  void _showBudgetDialog(
    CategoryBudgetRow? existingBudget,
    MockCategory category,
  ) {
    final controller = TextEditingController(
      text: existingBudget?.budgetAmount.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var saving = false;
        var deleting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final busy = saving || deleting;
            return AlertDialog(
              title: Text('Set Budget for ${category.name}'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: currency,
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(100, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: busy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                ),
                if (existingBudget != null)
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(100, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                    onPressed: busy
                        ? null
                        : () async {
                            setDialogState(() => deleting = true);
                            await _deleteBudget(category.id);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: busyButton(
                      context: context,
                      busy: deleting,
                      label: 'Delete',
                      size: 20,
                      indicatorColor: const Color(0xFFDC2626),
                    ),
                  ),
                FilledButton(
                  style: busyDialog(context),
                  onPressed: busy
                      ? null
                      : () async {
                          final amount = int.tryParse(controller.text);
                          if (amount == null || amount <= 0) return;
                          setDialogState(() => saving = true);
                          await _setBudget(category.id, amount);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  child: busyButton(
                    context: context,
                    busy: saving,
                    label: 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
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
                  'Could not load categories. Check your connection and try again.',
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
                final rows = context.watch<CategoryBudgetProvider>().budgets;
                final existingBudget = rows
                    .where((cb) => cb.categoryId == category.id)
                    .firstOrNull;

                final scheme = Theme.of(context).colorScheme;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: scheme.surface,
                  surfaceTintColor: Colors.transparent,
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
                    title: Text(
                      category.name,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: existingBudget != null
                        ? Text(
                            'Budget: ${formatMoney(existingBudget.budgetAmount.toDouble())}',
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.75),
                            ),
                          )
                        : Text(
                            'No budget set',
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showBudgetDialog(existingBudget, category),
                    ),
                    onTap: () => _showBudgetDialog(existingBudget, category),
                  ),
                );
              },
            ),
    );
  }
}
