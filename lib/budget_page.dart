import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'budget_provider.dart';
import 'functions.dart';
import 'transaction_provider.dart';
import 'category_budget_page.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});
  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BudgetProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final spent = txProvider.periodSpent(isWeekly: bp.isWeekly);
    final budget = bp.budget.amount;
    final left = (budget - spent).clamp(0.0, double.infinity);
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final periodLabel = bp.periodLabel;
    final categorySpending = txProvider.getCategorySpending(
      isWeekly: bp.isWeekly,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          '$periodLabel Budget',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoryBudgetPage()),
              );
            },
            child: const Text('Categories'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3e7f3f), Color(0xFF6abf69)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3e7f3f).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$periodLabel Budget',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    budget > 0 ? formatMoney(budget) : 'Not set',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _BudgetStat(
                          'Spent',
                          formatMoney(spent),
                          Colors.white,
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Expanded(
                        child: _BudgetStat(
                          'Remaining',
                          formatMoney(left),
                          Colors.white,
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
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}% used',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (categorySpending.isNotEmpty)
              _CategorySpendingChart(
                isWeekly: bp.isWeekly,
                categorySpending: categorySpending,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategorySpendingChart extends StatelessWidget {
  final bool isWeekly;
  final Map<String, double> categorySpending;

  const _CategorySpendingChart({
    required this.isWeekly,
    required this.categorySpending,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpent = categorySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final sections = categorySpending.entries.map((entry) {
      final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0;
      return PieChartSectionData(
        value: entry.value,
        title: percentage >= 10 ? entry.key : '',
        color: _getCategoryColor(entry.key),
        radius: 68,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isWeekly ? 'Weekly' : 'Monthly'} Spending by Category',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 4,
                centerSpaceRadius: 48,
                borderData: FlBorderData(show: false),
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categorySpending.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key}: ${formatMoney(entry.value)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
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

    return colorMap[category] ??
        Colors.primaries[category.hashCode % Colors.primaries.length];
  }
}

class _BudgetStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BudgetStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      Text(
        label,
        style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 18),
      ),
    ],
  );
}
