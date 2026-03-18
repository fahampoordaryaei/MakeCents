import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'transaction_provider.dart';
import 'budget_provider.dart';
import 'functions.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});
  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  static const int _historyPageSize = 10;
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();
  ExpenseCategory? _selectedCat;
  bool _showOverBudgetWarning = true;
  bool _isLoadingCategories = true;
  int _historyPage = 0;

  String _dayKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final connector = ExampleConnector.instance;
      final result = await connector.listExpenseCategories().execute();
      setState(() {
        dynamicCategories = result.data.expenseCategories.map((c) {
          return ExpenseCategory(
            c.id,
            c.name,
            getIconByName(c.iconName),
            Color(int.parse(c.colorHex.replaceFirst('#', '0xFF'))),
          );
        }).toList();

        if (dynamicCategories.isNotEmpty) {
          _selectedCat = dynamicCategories[0];
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _addAndNotify(String label, double amount) async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    try {
      await txProvider.addTransaction(
        label,
        amount,
        DateTime.now(),
        categoryName: _selectedCat!.name,
        categoryId: _selectedCat!.id,
      );
    } catch (e) {
      debugPrint('Failure adding transaction: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add transaction.')),
      );
      return;
    }
    _amountController.clear();
    _labelController.clear();
    if (!mounted) return;
    setState(() => _historyPage = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added €${amount.toStringAsFixed(2)} · ${_selectedCat!.name}',
        ),
        backgroundColor: const Color(0xFF3e7f3f),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedCat == null) return;
    final input = _amountController.text.trim();
    if (input.isEmpty) return;
    final amount = double.tryParse(input);
    if (amount == null || amount <= 0) return;
    final label = _labelController.text.trim().isEmpty
        ? _selectedCat!.name
        : _labelController.text.trim();
    final budget = Provider.of<BudgetProvider>(
      context,
      listen: false,
    ).budget.amount;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final currentExp = txProvider.monthlySpent;

    if (_showOverBudgetWarning && budget > 0 && currentExp + amount > budget) {
      await _overBudgetDialog(amount, budget, currentExp, label);
    } else {
      await _addAndNotify(label, amount);
    }
  }

  Future<void> _overBudgetDialog(
    double amount,
    double budget,
    double current,
    String label,
  ) async {
    bool dontShow = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Budget notice'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adding this will exceed your budget by €${(current + amount - budget).toStringAsFixed(2)}.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: dontShow,
                    onChanged: (v) => ss(() => dontShow = v ?? false),
                  ),
                  const Text("Don't show again"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3e7f3f),
              ),
              onPressed: () async {
                if (dontShow) setState(() => _showOverBudgetWarning = false);
                Navigator.pop(ctx);
                await _addAndNotify(label, amount);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDialog(TransactionProvider p, int idx, double amount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Expense'),
        content: Text(
          'Remove €${amount.toStringAsFixed(2)}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              p.removeTransaction(idx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editDialog(TransactionProvider p, Transaction tx) async {
    final titleController = TextEditingController(text: tx.title);
    final amountController = TextEditingController(
      text: tx.amount.toStringAsFixed(2),
    );
    DateTime selectedDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
    final dateController = TextEditingController(
      text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
    );
    ExpenseCategory? selectedCategory = dynamicCategories
        .where((c) => c.name == tx.category)
        .cast<ExpenseCategory?>()
        .firstWhere(
          (c) => c != null,
          orElse: () =>
              dynamicCategories.isNotEmpty ? dynamicCategories[0] : null,
        );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, ss) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit expense',
                        style: TextStyle(
                          fontSize: 20,
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
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                              color: Color(0xFF3e7f3f),
                            ),
                          ),
                        )
                      else if (dynamicCategories.isEmpty)
                        Text(
                          'No categories loaded',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        )
                      else
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dynamicCategories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = dynamicCategories[i];
                              final sel =
                                  selectedCategory != null &&
                                  cat.name == selectedCategory!.name;
                              return GestureDetector(
                                onTap: () => ss(() => selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? cat.color
                                        : cat.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        cat.icon,
                                        size: 15,
                                        color: sel ? Colors.white : cat.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          fontSize: 15,
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              titleController,
                              'Label (optional)',
                              null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(amountController, 'Amount', '€'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            ss(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                              );
                              dateController.text =
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Edit Date',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final parsedAmount = double.tryParse(
                              amountController.text.trim(),
                            );
                            final trimmedTitle = titleController.text.trim();
                            if (selectedCategory == null ||
                                parsedAmount == null ||
                                parsedAmount <= 0) {
                              return;
                            }
                            final safeTitle = trimmedTitle.isEmpty
                                ? selectedCategory!.name
                                : trimmedTitle;
                            try {
                              await p.updateTransaction(
                                id: tx.id,
                                title: safeTitle,
                                amount: parsedAmount,
                                date: selectedDate,
                                categoryId: selectedCategory!.id,
                                categoryName: selectedCategory!.name,
                              );
                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            } catch (_) {
                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to update transaction.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF3e7f3f),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save_outlined),
                          label: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    titleController.dispose();
    amountController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budget = Provider.of<BudgetProvider>(context).budget.amount;
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
    final monthTxs = txs
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
    final expenses = txP.monthlySpent;
    final available = budget > 0
        ? (budget - expenses).clamp(0.0, double.infinity)
        : 0.0;
    final over = budget > 0 && expenses > budget;
    final pct = budget > 0 ? (expenses / budget).clamp(0.0, 1.0) : 0.0;

    final Map<String, double> catTotals = {};
    for (final t in monthTxs) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }
    const groupThreshold = 0.10; // 10%
    const labelThreshold = 0.05; // 5%
    final totalForPct = expenses + (budget > 0 ? available : 0);
    final groupedCatTotals = <String, double>{};
    double otherTotal = 0;
    for (final e in catTotals.entries) {
      final pct = totalForPct > 0 ? (e.value / totalForPct) : 0;
      if (pct < groupThreshold) {
        otherTotal += e.value;
      } else {
        groupedCatTotals[e.key] = e.value;
      }
    }
    if (otherTotal > 0) {
      groupedCatTotals['Other'] = otherTotal;
    }
    final groupedEntries = groupedCatTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final today = DateTime.now();
    final histogramStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 29));
    final histogramByDay = <String, double>{};
    for (final t in txs) {
      final dayKey = _dayKey(t.date);
      histogramByDay[dayKey] = (histogramByDay[dayKey] ?? 0) + t.amount;
    }
    final last30DailySpend = List<double>.generate(30, (i) {
      final day = histogramStart.add(Duration(days: i));
      return histogramByDay[_dayKey(day)] ?? 0.0;
    });
    final maxDaily = last30DailySpend.fold<double>(0.0, math.max);
    final maxY = maxDaily <= 0 ? 20.0 : (maxDaily / 20).ceil() * 20.0;
    const yInterval = 20.0;
    final total30Days = last30DailySpend.fold(0.0, (sum, v) => sum + v);

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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              txs.isEmpty
                  ? 'No expenses yet'
                  : '${txs.length} expense${txs.length == 1 ? '' : 's'} recorded',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Budget card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: over
                      ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                      : [const Color(0xFF3e7f3f), const Color(0xFF6abf69)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (over ? Colors.redAccent : const Color(0xFF3e7f3f))
                        .withValues(alpha: 0.3),
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
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            budget > 0
                                ? '€${budget.toStringAsFixed(2)}'
                                : 'Not set',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          over ? '⚠ Over Budget' : '✓ On Track',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
                          '€${expenses.toStringAsFixed(2)}',
                          Icons.arrow_upward_rounded,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      Expanded(
                        child: _Stat(
                          'Available',
                          '€${available.toStringAsFixed(2)}',
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
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}% of budget used',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Add expense card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingCategories)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: Color(0xFF3e7f3f),
                          ),
                        ),
                      )
                    else if (dynamicCategories.isEmpty)
                      Text(
                        'No categories loaded',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      )
                    else
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: dynamicCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final cat = dynamicCategories[i];
                            final sel =
                                _selectedCat != null &&
                                cat.name == _selectedCat!.name;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCat = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? cat.color
                                      : cat.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat.icon,
                                      size: 14,
                                      color: sel ? Colors.white : cat.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 14,
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            _labelController,
                            'Label (optional)',
                            null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(_amountController, 'Amount', '€'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF3e7f3f),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Add Expense',
                          style: TextStyle(
                            fontSize: 16,
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

            // Last 30 days histogram
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 30 Days Spending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: €${total30Days.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: SizedBox(
                          width: 900,
                          child: BarChart(
                            BarChartData(
                              minY: 0,
                              maxY: maxY,
                              alignment: BarChartAlignment.spaceBetween,
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                horizontalInterval: yInterval,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.12),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, _, rod, _) =>
                                      BarTooltipItem(
                                        '€${rod.toY.toStringAsFixed(2)}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 44,
                                    interval: yInterval,
                                    getTitlesWidget: (value, _) => Text(
                                      '€${value.toInt()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, _) {
                                      final i = value.toInt();
                                      if (i < 0 || i >= 30) {
                                        return const SizedBox.shrink();
                                      }
                                      if (i % 5 != 0 && i != 29) {
                                        return const SizedBox.shrink();
                                      }
                                      final d = histogramStart.add(
                                        Duration(days: i),
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          '${d.day}/${d.month}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.75),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(30, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: last30DailySpend[i],
                                      width: 10,
                                      borderRadius: BorderRadius.circular(3),
                                      color: const Color(0xFF3e7f3f),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chart
            if (txs.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                                    color: Colors.green.withValues(
                                      alpha:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? 0.9
                                          : 0.8,
                                    ),
                                    value: available,
                                    title: pct >= labelThreshold
                                        ? '€${available.toStringAsFixed(0)}'
                                        : '',
                                    radius: pct >= groupThreshold ? 60 : 55,
                                    titleStyle: TextStyle(
                                      fontSize: 16,
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
                                    ? ExpenseCategory(
                                        'other',
                                        'Other',
                                        Icons.more_horiz,
                                        Colors.grey,
                                      )
                                    : catFor(e.key);
                                final pct = totalForPct > 0
                                    ? (e.value / totalForPct)
                                    : 0;
                                return PieChartSectionData(
                                  color: c.color,
                                  value: e.value,
                                  title: pct >= labelThreshold
                                      ? '€${e.value.toStringAsFixed(0)}'
                                      : '',
                                  radius: pct >= groupThreshold ? 60 : 55,
                                  titleStyle: TextStyle(
                                    fontSize: 16,
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
                              Colors.green.withValues(alpha: 0.7),
                              'Available €${available.toStringAsFixed(0)}',
                            ),
                          ...groupedEntries.map(
                            (e) => _Chip(
                              e.key == 'Other'
                                  ? Colors.grey
                                  : catFor(e.key).color,
                              '${e.key} €${e.value.toStringAsFixed(0)}',
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

            // History
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                              fontSize: 15,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (txP.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3e7f3f),
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
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No expenses yet.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.75),
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
                        itemBuilder: (ctx, i) {
                          final globalI = pageStart + i;
                          final idx = txs.length - 1 - globalI;
                          final tx = txs[idx];
                          final cat = catFor(tx.category);
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 20),
                            ),
                            title: Text(
                              tx.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${cat.name} · ${_fmt(tx.date)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
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
                                          minimumSize: const Size(50, 36),
                                          visualDensity: VisualDensity.compact,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _deleteDialog(txP, idx, tx.amount),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 13,
                                        ),
                                        label: const Text('Delete'),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(50, 36),
                                          foregroundColor: Colors.redAccent,
                                          side: const BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '-€${tx.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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

  Widget _field(TextEditingController c, String label, String? prefix) {
    return TextField(
      controller: c,
      keyboardType: prefix != null
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
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
          fontSize: 24,
        ),
      ),
      Text(
        l,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
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
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}
