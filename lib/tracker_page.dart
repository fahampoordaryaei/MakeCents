// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.name, this.icon, this.color);
}

List<ExpenseCategory> _dynamicCategories = [];

IconData _getIcon(String name) {
  switch (name) {
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'favorite':
      return Icons.favorite;
    case 'school':
      return Icons.school;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'receipt_long':
      return Icons.receipt_long;
    default:
      return Icons.more_horiz;
  }
}

ExpenseCategory catFor(String name) => _dynamicCategories.firstWhere(
  (c) => c.name == name,
  orElse: () => _dynamicCategories.isNotEmpty
      ? _dynamicCategories.last
      : const ExpenseCategory('Other', Icons.more_horiz, Colors.grey),
);

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});
  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();
  ExpenseCategory? _selectedCat;
  bool _showOverBudgetWarning = true;
  bool _isLoadingCategories = true;

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
        _dynamicCategories = result.data.expenseCategories.map((c) {
          return ExpenseCategory(
            c.name,
            _getIcon(c.iconName),
            Color(int.parse(c.colorHex.replaceFirst('#', '0xFF'))),
          );
        }).toList();
        if (_dynamicCategories.isNotEmpty) {
          _selectedCat = _dynamicCategories[0];
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
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
    final currentExp = txProvider.transactions.fold(
      0.0,
      (s, t) => s + t.amount,
    );

    if (_showOverBudgetWarning && budget > 0 && currentExp + amount > budget) {
      await _overBudgetDialog(amount, budget, currentExp, label);
    } else {
      await txProvider.addTransaction(
        label,
        amount,
        DateTime.now(),
        category: _selectedCat!.name,
      );
      _amountController.clear();
      _labelController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added \$${amount.toStringAsFixed(2)} · ${_selectedCat!.name}',
          ),
          backgroundColor: const Color(0xFF3e7f3f),
        ),
      );
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
              Text('Over Budget'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adding this will exceed your budget by \$${(current + amount - budget).toStringAsFixed(2)}.',
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
                await Provider.of<TransactionProvider>(
                  context,
                  listen: false,
                ).addTransaction(
                  label,
                  amount,
                  DateTime.now(),
                  category: _selectedCat!.name,
                );
                _amountController.clear();
                _labelController.clear();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added \$${amount.toStringAsFixed(2)} · $label',
                    ),
                    backgroundColor: const Color(0xFF3e7f3f),
                  ),
                );
              },
              child: const Text('Add Anyway'),
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
          'Remove \$${amount.toStringAsFixed(2)}? This cannot be undone.',
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

  @override
  Widget build(BuildContext context) {
    final budget = Provider.of<BudgetProvider>(context).budget.amount;
    final txP = Provider.of<TransactionProvider>(context);
    final txs = txP.transactions;
    final expenses = txs.fold(0.0, (s, t) => s + t.amount);
    final available = budget > 0
        ? (budget - expenses).clamp(0.0, double.infinity)
        : 0.0;
    final over = budget > 0 && expenses > budget;
    final pct = budget > 0 ? (expenses / budget).clamp(0.0, 1.0) : 0.0;

    final Map<String, double> catTotals = {};
    for (final t in txs) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }

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
              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            budget > 0
                                ? '\$${budget.toStringAsFixed(2)}'
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
                          '\$${expenses.toStringAsFixed(2)}',
                          Icons.arrow_upward_rounded,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      Expanded(
                        child: _Stat(
                          'Available',
                          '\$${available.toStringAsFixed(2)}',
                          Icons.savings_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (budget > 0) ...[
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 6),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}% of budget used',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
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
                    else if (_dynamicCategories.isEmpty)
                      const Text(
                        'No categories loaded',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _dynamicCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final cat = _dynamicCategories[i];
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
                          child: _field(_amountController, 'Amount', '\$ '),
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
                                PieChartSectionData(
                                  color: Colors.green.withValues(
                                    alpha:
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                        ? 0.9
                                        : 0.8,
                                  ),
                                  value: available,
                                  title: '',
                                  radius: 50,
                                ),
                              ...catTotals.entries.map((e) {
                                final c = catFor(e.key);
                                final isLarge =
                                    e.value > (expenses + available) * 0.1;
                                return PieChartSectionData(
                                  color: c.color,
                                  value: e.value,
                                  title: isLarge
                                      ? '\$${e.value.toStringAsFixed(0)}'
                                      : '',
                                  radius: isLarge ? 60 : 55,
                                  titleStyle: TextStyle(
                                    fontSize: isLarge ? 22 : 20,
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
                              'Available \$${available.toStringAsFixed(0)}',
                            ),
                          ...catTotals.entries.map(
                            (e) => _Chip(
                              catFor(e.key).color,
                              '${e.key} \$${e.value.toStringAsFixed(0)}',
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
                            style: const TextStyle(
                              color: Colors.grey,
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
                      const Padding(
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
                                'No expenses yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txs.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final idx = txs.length - 1 - i;
                          final tx = txs[idx];
                          final cat = catFor(tx.category);
                          return ListTile(
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
                            subtitle: Text(
                              '${cat.name} · ${_fmt(tx.date)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '-\$${tx.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _deleteDialog(txP, idx, tx.amount),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(height: 4),
      Text(
        v,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      Text(l, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
