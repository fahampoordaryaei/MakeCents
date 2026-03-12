import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';
import 'user_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = DateFormat('EEEE, MMMM d').format(now);
    final txProvider = Provider.of<TransactionProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final displayName = userProvider.profile?.firstName ?? 'Student';

    final expenses = txProvider.transactions.fold(0.0, (s, t) => s + t.amount);
    final budget = budgetProvider.budget.amount;
    final available = budget > 0 ? (budget - expenses).clamp(0.0, budget) : 0.0;
    final spentPct = budget > 0 ? (expenses / budget).clamp(0.0, 1.0) : 0.0;
    final recent = txProvider.transactions.reversed.take(3).toList();

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hey, $displayName! 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Budget summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3e7f3f), Color(0xFF6abf69)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3e7f3f).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Budget',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      budget > 0 ? '\$${budget.toStringAsFixed(2)}' : 'Not set',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: 'Spent',
                            value: '\$${expenses.toStringAsFixed(2)}',
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Left',
                            value: '\$${available.toStringAsFixed(2)}',
                            icon: Icons.savings_outlined,
                          ),
                        ),
                      ],
                    ),
                    if (budget > 0) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: spentPct,
                          minHeight: 7,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(spentPct * 100).toStringAsFixed(0)}% of budget used',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Quick stats row
              Row(
                children: [
                  Expanded(
                    child: _QuickStatCard(
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFF4ECDC4),
                      label: 'Transactions',
                      value: '${txProvider.transactions.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStatCard(
                      icon: Icons.trending_down_outlined,
                      color: const Color(0xFFFF6B6B),
                      label: "Spent today",
                      value:
                          '\$${_todaySpend(txProvider.transactions).toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent transactions
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'No transactions yet.\nAdd one using the Tracker tab.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 64),
                    itemBuilder: (context, i) {
                      final tx = recent[i];
                      final cat = _catFor(tx.category);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.15),
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
                          DateFormat('MMM d').format(tx.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Text(
                          '-\$${tx.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _todaySpend(List<Transaction> txs) {
    final today = DateTime.now();
    return txs
        .where(
          (t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day,
        )
        .fold(0.0, (s, t) => s + t.amount);
  }

  _CatData _catFor(String name) {
    const map = {
      'Food': _CatData(Icons.restaurant, Color(0xFFFF6B6B)),
      'Transport': _CatData(Icons.directions_bus, Color(0xFF4ECDC4)),
      'Shopping': _CatData(Icons.shopping_bag, Color(0xFFFFE66D)),
      'Health': _CatData(Icons.favorite, Color(0xFF95E1D3)),
      'Education': _CatData(Icons.school, Color(0xFFA8D8EA)),
      'Entertainment': _CatData(Icons.sports_esports, Color(0xFFAA96DA)),
      'Bills': _CatData(Icons.receipt_long, Color(0xFFFC5185)),
    };
    return map[name] ?? const _CatData(Icons.more_horiz, Color(0xFFB2B2B2));
  }
}

class _CatData {
  final IconData icon;
  final Color color;
  const _CatData(this.icon, this.color);
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _QuickStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
