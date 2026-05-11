import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/helper/ui_helper.dart';
import 'package:makecents/helper/currency_helper.dart';
import 'package:makecents/provider/category_provider.dart';

import 'package:makecents/provider/budget_provider.dart';
import 'package:makecents/provider/category_budget_provider.dart';
import 'package:makecents/provider/transaction_provider.dart';
import 'package:makecents/widget/busy_button.dart';

Widget _trackerTextField(
  BuildContext context,
  TextEditingController controller,
  String label,
  String? prefix, {
  TextStyle? labelStyle,
  TextStyle? style,
  bool readOnly = false,
  VoidCallback? onTap,
  Widget? suffixIcon,
}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    style: style,
    keyboardType: prefix != null
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: labelStyle,
      prefixText: prefix,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});
  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  static const int _historyPageSize = 10;
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();
  final _categoriesScrollController = ScrollController();
  Category? _selectedCategory;
  bool _isLoadingCategories = true;
  int _historyPage = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initCategoryBudgets();
  }

  void _initCategoryBudgets() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<CategoryBudgetProvider>().load(uid);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    _categoriesScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final connector = ExampleConnector.instance;
      final result = await connector.listCategories().execute();
      if (!mounted) return;
      setState(() {
        setCategories(result.data.categories);

        if (categories.isNotEmpty) {
          _selectedCategory = categories[0];
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('tracker_page._loadCategories failed: $e');
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _openCategoryBudgetDialog() async {
    final root = context;
    String selectedId = (_selectedCategory ?? categories.first).id;
    double currentBudget(String categoryId) {
      final existing = root
          .read<CategoryBudgetProvider>()
          .budgets
          .where((b) => b.categoryId == categoryId)
          .firstOrNull;
      return (existing?.budgetAmount ?? 0).toDouble().clamp(0.0, 10000.0);
    }

    double sliderVal = currentBudget(selectedId);
    final amountController = TextEditingController(
      text: sliderVal.toInt().toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Category Budget',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 280,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey<String>(selectedId),
                        initialValue: selectedId,
                        itemHeight: 60,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelStyle: TextStyle(fontSize: 20),
                          contentPadding: const EdgeInsets.fromLTRB(
                            16,
                            20,
                            16,
                            20,
                          ),
                        ),
                        items: categories
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: c.color.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        c.icon,
                                        size: 14,
                                        color: c.color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        color: c.color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        selectedItemBuilder: (context) {
                          return categories.map((c) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: c.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(c.icon, size: 24, color: c.color),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: c.color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                        onChanged: (value) {
                          setDialogState(() {
                            selectedId = value!;
                            sliderVal = currentBudget(value);
                            amountController.text = sliderVal
                                .toInt()
                                .toString();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (_) {
                          final v = double.tryParse(
                            amountController.text.trim(),
                          );
                          if (v == null) return;
                          setDialogState(() {
                            sliderVal = v.clamp(0.0, 10000.0);
                          });
                        },
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixText: currency,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          inactiveTrackColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.25),
                          thumbColor: Theme.of(context).colorScheme.primary,
                          trackHeight: 6.0,
                        ),
                        child: Slider(
                          value: sliderVal,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          onChanged: (v) {
                            setDialogState(() {
                              sliderVal = v;
                              amountController.text = v.toInt().toString();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currency}0',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${currency}10,000',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final had = root.read<CategoryBudgetProvider>().budgets.any(
                      (b) => b.categoryId == selectedId,
                    );
                    if (!had) {
                      nav.pop();
                      return;
                    }
                    await root.read<CategoryBudgetProvider>().delete(
                      uid,
                      selectedId,
                    );
                    nav.pop();
                    if (!mounted) return;
                    setState(() {});
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final selected = categories.firstWhere(
                      (c) => c.id == selectedId,
                      orElse: () => categories.first,
                    );
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    final nextAmount = amount?.round() ?? 0;
                    await root.read<CategoryBudgetProvider>().upsert(
                      uid,
                      selected.id,
                      nextAmount,
                    );
                    nav.pop();
                    if (!mounted) return;
                    setState(() {});
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      amountController.dispose();
    });
  }

  Future<void> _addExpense(double amount, {String? description}) async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    try {
      await txProvider.addTransaction(
        amount,
        DateTime.now(),
        description: description,
        categoryName: _selectedCategory!.name,
        categoryId: _selectedCategory!.id,
      );
    } catch (e) {
      debugPrint('tracker_page._addExpense failed: $e');
      if (!mounted) return;
      await popupAlert(
        context,
        message: 'Failed to add transaction.',
        level: AppAlertLevel.error,
      );
      return;
    }
    if (!mounted) return;
    _amountController.clear();
    _labelController.clear();
    setState(() => _historyPage = 0);
    await popupAlert(
      context,
      message: 'Added ${formatMoney(amount)} · ${_selectedCategory!.name}',
      level: AppAlertLevel.success,
    );
  }

  Future<void> _submit() async {
    final input = _amountController.text.trim();
    if (input.isEmpty) return;
    final amount = double.tryParse(input);
    if (amount == null || amount <= 0) return;
    final memo = _labelController.text.trim();
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final budget = bp.budget.amount;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    final selectedCat = _selectedCategory!;
    final catBudget = context
        .read<CategoryBudgetProvider>()
        .budgets
        .where((b) => b.categoryId == selectedCat.id)
        .firstOrNull;
    if (catBudget != null) {
      final spentByCategory = txProvider.getCategorySpending(
        isWeekly: bp.isWeekly,
      );

      final selectedSpent = spentByCategory[selectedCat.name] ?? 0.0;
      final catLimit = catBudget.budgetAmount.toDouble();
      if (selectedSpent + amount > catLimit) {
        await popupAlert(
          context,
          message: 'Expense not added:\nNot enough ${selectedCat.name} budget!',
          level: AppAlertLevel.error,
        );
        return;
      }
    }
    final currentExp = txProvider.periodSpent(isWeekly: bp.isWeekly);
    final overBudget = budget > 0 && currentExp + amount > budget;

    if (overBudget) {
      if (!bp.allowOverBudget) {
        await popupAlert(
          context,
          message: 'Watch your spending!\nThis expense exceeds your budget.',
          level: AppAlertLevel.error,
        );
        return;
      }
      await popupAlert(
        context,
        message: 'Warning:\nYou have gone over your budget!',
        level: AppAlertLevel.warning,
      );
    }
    await _addExpense(amount, description: memo.isEmpty ? null : memo);
  }

  void _deleteDialog(TransactionProvider p, int idx, double amount) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Delete Expense?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: Text(
            'Remove ${formatMoney(amount)}?\n\nThis action cannot be undone.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 0.9),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(100, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              minimumSize: const Size(100, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await p.removeTransaction(idx);
              } catch (e) {
                debugPrint('Remove transaction failed: $e');
                if (!mounted) return;
                await popupAlert(
                  context,
                  message: 'Could not delete expense.',
                  level: AppAlertLevel.error,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Future<void> _editDialog(TransactionProvider p, Transaction tx) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTransactionSheet(
        tx: tx,
        provider: p,
        categoriesLoading: _isLoadingCategories,
        messengerContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bp = Provider.of<BudgetProvider>(context);
    final catBudgetRows = context.watch<CategoryBudgetProvider>().budgets;
    final budget = bp.budget.amount;
    final txP = Provider.of<TransactionProvider>(context);
    final txs = txP.transactions;
    final totalPages = txs.isEmpty
        ? 1
        : ((txs.length - 1) ~/ _historyPageSize) + 1;
    final currentPage = _historyPage >= totalPages
        ? totalPages - 1
        : _historyPage;
    final pageStart = currentPage * _historyPageSize;
    final pageEndExclusive = (pageStart + _historyPageSize) > txs.length
        ? txs.length
        : (pageStart + _historyPageSize);
    final now = DateTime.now();
    final isWeekly = bp.isWeekly;
    final today = DateTime(now.year, now.month, now.day);
    final periodStart = isWeekly
        ? today.subtract(Duration(days: today.weekday - 1))
        : DateTime(now.year, now.month, 1);
    final periodTxs = txs.where((t) => !t.date.isBefore(periodStart)).toList();
    final expenses = txP.periodSpent(isWeekly: isWeekly);
    final available = budget > 0
        ? (budget - expenses).clamp(0.0, double.infinity)
        : 0.0;
    final over = budget > 0 && expenses > budget;
    final pct = budget > 0 ? (expenses / budget).clamp(0.0, 1.0) : 0.0;
    final spentLabel = isWeekly ? 'Spent this week' : 'Spent this month';

    final Map<String, double> catTotals = {};
    for (final t in periodTxs) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }
    const labelThreshold = 0.05;
    const groupThreshold = 0.03;
    const maxCategoriesToShow = 8;
    final totalForPct = expenses + (budget > 0 ? available : 0);

    final groupedCatTotals = Map<String, double>.from(catTotals);
    if (groupedCatTotals.length > maxCategoriesToShow) {
      final smallCategories = groupedCatTotals.entries
          .where(
            (e) => totalForPct > 0
                ? (e.value / totalForPct) < groupThreshold
                : false,
          )
          .toList();

      if (smallCategories.length > 1) {
        double otherTotal = 0;
        for (final e in smallCategories) {
          otherTotal += e.value;
          groupedCatTotals.remove(e.key);
        }
        if (otherTotal > 0) {
          groupedCatTotals['Other'] = otherTotal;
        }
      }

      if (groupedCatTotals.length > maxCategoriesToShow) {
        final sortedEntries = groupedCatTotals.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        while (groupedCatTotals.length > maxCategoriesToShow &&
            sortedEntries.isNotEmpty) {
          final smallest = sortedEntries.removeAt(0);
          final existingOther = groupedCatTotals.remove('Other') ?? 0;
          groupedCatTotals['Other'] = existingOther + smallest.value;
        }
      }
    }

    final groupedEntries = groupedCatTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final spentByCategory = <String, double>{};
    for (final e in groupedEntries) {
      spentByCategory[e.key.toLowerCase()] = e.value;
    }
    final categoryBudgetPreview = catBudgetRows.take(10).map((b) {
      final cat = categoryFor(b.categoryName);
      final spent = spentByCategory[b.categoryName.toLowerCase()] ?? 0.0;
      return (
        name: b.categoryName,
        spent: spent,
        limit: b.budgetAmount.toDouble(),
        icon: cat.icon,
        color: cat.color,
      );
    }).toList();

    final daysIntoPeriod = isWeekly ? now.weekday : now.day;
    final dailySpend = <int, double>{};
    for (final t in periodTxs) {
      final dayIdx = t.date.difference(periodStart).inDays + 1;
      if (dayIdx < 1 || dayIdx > daysIntoPeriod) continue;
      dailySpend[dayIdx] = (dailySpend[dayIdx] ?? 0) + t.amount;
    }
    final spendChartPoints = <_SpendChartPoint>[_SpendChartPoint(0, 0)];
    double runningTotal = 0;
    for (var d = 1; d <= daysIntoPeriod; d++) {
      runningTotal += dailySpend[d] ?? 0;
      spendChartPoints.add(_SpendChartPoint(d.toDouble(), runningTotal));
    }
    final chartMaxX = daysIntoPeriod > 0 ? daysIntoPeriod.toDouble() : 1.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: over
                      ? [
                          const Color.fromARGB(255, 197, 51, 51),
                          const Color.fromARGB(255, 203, 106, 71),
                        ]
                      : [const Color(0xFF3e7f3f), const Color(0xFF6abf69)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (over ? scheme.error : scheme.primary).withValues(
                      alpha: 0.28,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Budget',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            formatMoney(budget),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          over ? '⚠ Over Budget' : '✓ On Track',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          'Spent',
                          formatMoney(expenses),
                          Icons.arrow_upward_rounded,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      Expanded(
                        child: _Stat(
                          'Available',
                          formatMoney(available),
                          Icons.savings_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (budget > 0) ...[
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.white38,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}% of budget used',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Category Budgets',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  await _openCategoryBudgetDialog();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...categoryBudgetPreview.map((item) {
                            final cPct = (item.spent / item.limit).clamp(
                              0.0,
                              1.5,
                            );
                            final tone = cPct >= 1
                                ? const Color(0xFFFCA5A5)
                                : cPct >= 0.8
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFBBF7D0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(item.icon, size: 32, color: tone),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 54,
                                    child: Text(
                                      formatMoney(item.spent, decimals: 0),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: cPct.clamp(0.0, 1.0),
                                        minHeight: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(tone),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 54,
                                    child: Text(
                                      formatMoney(item.limit, decimals: 0),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Card(
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Expense',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingCategories)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: scheme.primary,
                          ),
                        ),
                      )
                    else if (categories.isEmpty)
                      Text(
                        'No categories loaded',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      )
                    else
                      Scrollbar(
                        controller: _categoriesScrollController,
                        interactive: true,
                        thumbVisibility: true,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        thickness: 8,
                        radius: const Radius.circular(8),
                        child: SizedBox(
                          height: 60,
                          child: ListView.separated(
                            controller: _categoriesScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            padding: const EdgeInsets.only(bottom: 18),
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = categories[i];
                              final sel =
                                  _selectedCategory != null &&
                                  cat.name == _selectedCategory!.name;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? cat.color
                                        : cat.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        cat.icon,
                                        size: 24,
                                        color: sel ? Colors.white : cat.color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: sel ? Colors.white : cat.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _trackerTextField(
                            context,
                            _labelController,
                            'Label (optional)',
                            null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _trackerTextField(
                            context,
                            _amountController,
                            'Amount',
                            currency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          disabledBackgroundColor:
                              scheme.surfaceContainerHighest,
                          disabledForegroundColor: scheme.onSurface.withValues(
                            alpha: 0.38,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Add Expense',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spentLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatMoney(expenses),
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 168,
                      width: double.infinity,
                      child: _SpendChart(
                        points: spendChartPoints,
                        chartMaxX: chartMaxX,
                        periodStart: periodStart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (txs.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              if (budget > 0 && available > 0)
                                () {
                                  final pct = totalForPct > 0
                                      ? (available / totalForPct)
                                      : 0;
                                  return PieChartSectionData(
                                    color: scheme.primary.withValues(
                                      alpha:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? 0.9
                                          : 0.8,
                                    ),
                                    value: available,
                                    title: pct >= labelThreshold
                                        ? formatMoney(available, decimals: 0)
                                        : '',
                                    radius: pct >= groupThreshold ? 60 : 55,
                                    titleStyle: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                }(),
                              ...groupedEntries.map((e) {
                                final c = e.key == 'Other'
                                    ? Category(
                                        'other',
                                        'Other',
                                        Icons.more_horiz,
                                        scheme.onSurfaceVariant,
                                      )
                                    : categoryFor(e.key);
                                final pct = totalForPct > 0
                                    ? (e.value / totalForPct)
                                    : 0;
                                return PieChartSectionData(
                                  color: c.color,
                                  value: e.value,
                                  title: pct >= labelThreshold
                                      ? formatMoney(e.value, decimals: 0)
                                      : '',
                                  radius: pct >= groupThreshold ? 60 : 55,
                                  titleStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  titlePositionPercentageOffset: 0.6,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          if (budget > 0)
                            _Chip(
                              scheme.primary.withValues(alpha: 0.75),
                              'Available ${formatMoney(available, decimals: 0)}',
                            ),
                          ...groupedEntries.map(
                            (e) => _Chip(
                              e.key == 'Other'
                                  ? scheme.onSurfaceVariant
                                  : categoryFor(e.key).color,
                              '${e.key} ${formatMoney(e.value, decimals: 0)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (txs.isNotEmpty)
                          Text(
                            '${txs.length} items',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.75),
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (txP.isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: scheme.primary,
                          ),
                        ),
                      )
                    else if (txs.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 40,
                                color: scheme.onSurfaceVariant,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No expenses yet.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.75),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pageEndExclusive - pageStart,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final globalI = pageStart + i;
                          final tx = txs[globalI];
                          final cat = categoryFor(tx.category);
                          return ListTile(
                            isThreeLine: true,
                            minVerticalPadding: 8,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 20),
                            ),
                            title: Text(
                              tx.displayLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tx.description == null
                                      ? _fmt(tx.date)
                                      : '${cat.name} · ${_fmt(tx.date)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () => _editDialog(txP, tx),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 13,
                                          ),
                                          label: const Text('Edit'),
                                          style: OutlinedButton.styleFrom(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            minimumSize: const Size(50, 40),
                                            visualDensity:
                                                VisualDensity.compact,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        OutlinedButton.icon(
                                          onPressed: () => _deleteDialog(
                                            txP,
                                            globalI,
                                            tx.amount,
                                          ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 13,
                                          ),
                                          label: const Text('Delete'),
                                          style: OutlinedButton.styleFrom(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            minimumSize: const Size(50, 40),
                                            foregroundColor: scheme.error,
                                            side: BorderSide(
                                              color: scheme.error,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '-${formatMoney(tx.amount)}',
                              style: TextStyle(
                                color: scheme.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    if (!txP.isLoading && txs.length > _historyPageSize) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: currentPage > 0
                                ? () => setState(
                                    () => _historyPage = currentPage - 1,
                                  )
                                : null,
                            child: const Text('Previous'),
                          ),
                          Text(
                            'Page ${currentPage + 1} of $totalPages',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: currentPage < totalPages - 1
                                ? () => setState(
                                    () => _historyPage = currentPage + 1,
                                  )
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    final n = DateTime.now();
    if (d.year == n.year && d.month == n.month && d.day == n.day) {
      return 'Today';
    }
    if (d.year == n.year && d.month == n.month && d.day == n.day - 1) {
      return 'Yesterday';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _EditTransactionSheet extends StatefulWidget {
  const _EditTransactionSheet({
    required this.tx,
    required this.provider,
    required this.categoriesLoading,
    required this.messengerContext,
  });

  final Transaction tx;
  final TransactionProvider provider;
  final bool categoriesLoading;
  final BuildContext messengerContext;

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _date;
  late DateTime _selectedDate;
  Category? _selectedCategory;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.tx;
    _title = TextEditingController(text: tx.description ?? '');
    _amount = TextEditingController(text: tx.amount.toStringAsFixed(2));
    _selectedDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
    _date = TextEditingController(
      text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
    );
    final match = categories.where((c) => c.name == tx.category);
    _selectedCategory = match.isNotEmpty
        ? match.first
        : (categories.isNotEmpty ? categories.first : null);
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
      _date.text =
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    });
  }

  Future<void> _saveExpense() async {
    final parsedAmount = double.tryParse(_amount.text.trim());
    final trimmedTitle = _title.text.trim();
    if (_selectedCategory == null ||
        parsedAmount == null ||
        parsedAmount <= 0) {
      return;
    }
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await widget.provider.updateTransaction(
        id: widget.tx.id,
        description: trimmedTitle.isEmpty ? null : trimmedTitle,
        amount: parsedAmount,
        date: _selectedDate,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
      );
      if (!mounted) return;
      navigator.pop();
    } catch (e) {
      debugPrint(
        'tracker_page._EditTransactionSheetState._saveExpense failed: $e',
      );
      if (!mounted) return;
      if (widget.messengerContext.mounted) {
        await popupAlert(
          widget.messengerContext,
          message: 'Failed to update transaction.',
          level: AppAlertLevel.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit expense',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.categoriesLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: scheme.primary),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey<String>(_selectedCategory?.id ?? ''),
                    initialValue: _selectedCategory!.id,
                    itemHeight: 56,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(fontSize: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      for (final c in categories)
                        DropdownMenuItem<String>(
                          value: c.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: c.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(c.icon, size: 16, color: c.color),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: c.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (id) {
                      if (id == null) return;
                      setState(
                        () => _selectedCategory = categories.firstWhere(
                          (c) => c.id == id,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _trackerTextField(
                    context,
                    _amount,
                    'Amount',
                    currency,
                    labelStyle: const TextStyle(fontSize: 18),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _trackerTextField(
                    context,
                    _title,
                    'Label (optional)',
                    null,
                    labelStyle: const TextStyle(fontSize: 18),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _trackerTextField(
                    context,
                    _date,
                    'Date',
                    null,
                    readOnly: true,
                    onTap: _pickDate,
                    labelStyle: const TextStyle(fontSize: 18),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 24),
                    FilledButton(
                      style: busySave(context),
                      onPressed: _saving ? null : _saveExpense,
                      child: busyButton(
                        context: context,
                        busy: _saving,
                        label: 'Save',
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpendChartPoint {
  const _SpendChartPoint(this.day, this.total);
  final double day;
  final double total;
}

class _SpendChart extends StatelessWidget {
  const _SpendChart({
    required this.points,
    required this.chartMaxX,
    required this.periodStart,
  });

  final List<_SpendChartPoint> points;
  final double chartMaxX;
  final DateTime periodStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartAccent = theme.colorScheme.primary;
    final axisLabelStyle = TextStyle(fontSize: 18);
    final yFormat = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    final dayMonthFmt = DateFormat('dd/MM');

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.only(bottom: 4),
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        lineType: TrackballLineType.vertical,
        lineWidth: 1.5,
        lineColor: chartAccent,
        hideDelay: 4000,
        markerSettings: TrackballMarkerSettings(
          markerVisibility: TrackballVisibilityMode.visible,
          height: 11,
          width: 11,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          color: Colors.white,
          borderColor: chartAccent,
        ),
        tooltipSettings: InteractiveTooltip(
          color: theme.colorScheme.surfaceContainerHighest,
          borderWidth: 0,
          borderRadius: 8,
          arrowLength: 0,
          arrowWidth: 0,
          canShowMarker: false,
        ),
        builder: (BuildContext context, TrackballDetails details) {
          final i = details.pointIndex;
          if (i == null || i < 0 || i >= points.length) {
            return const SizedBox.shrink();
          }
          final p = points[i];
          final day = p.day.round();
          final date = periodStart.add(Duration(days: day <= 0 ? 0 : day - 1));
          final dateStr = dayMonthFmt.format(date);
          final amountStr = day <= 0 ? formatMoney(0) : formatMoney(p.total);
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: DefaultTextStyle.merge(
                style: axisLabelStyle.copyWith(height: 1.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateStr,
                      style: axisLabelStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      amountStr,
                      style: axisLabelStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      primaryXAxis: NumericAxis(
        minimum: 0,
        maximum: chartMaxX,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        labelStyle: axisLabelStyle,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: const MajorGridLines(width: 0),
        axisLabelFormatter: (AxisLabelRenderDetails d) {
          final day = d.value.round();
          final date = periodStart.add(Duration(days: day <= 0 ? 0 : day - 1));
          return ChartAxisLabel(dayMonthFmt.format(date), d.textStyle);
        },
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        minimum: 0,
        numberFormat: yFormat,
        labelStyle: axisLabelStyle,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      series: <CartesianSeries<_SpendChartPoint, double>>[
        AreaSeries<_SpendChartPoint, double>(
          dataSource: points,
          xValueMapper: (p, _) => p.day,
          yValueMapper: (p, _) => p.total,
          borderColor: chartAccent,
          borderWidth: 3,
          gradient: LinearGradient(
            colors: [
              chartAccent.withValues(alpha: 0.14),
              chartAccent.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          enableTooltip: false,
          animationDuration: 500,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String l, v;
  final IconData icon;
  const _Stat(this.l, this.v, this.icon);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Colors.white, size: 24),
      const SizedBox(height: 6),
      Text(
        v,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
      ),
      Text(
        l,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  final Color color;
  final String label;
  const _Chip(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}
