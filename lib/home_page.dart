import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoadingHomeFeeds = true;
  List<ListProductsProducts> _unredeemedDeals = const [];
  List<ListScholarshipsScholarships> _matchedScholarships = const [];

  @override
  void initState() {
    super.initState();
    _loadHomeFeeds();
  }

  Future<void> _loadHomeFeeds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoadingHomeFeeds = false);
      return;
    }

    try {
      final connector = ExampleConnector.instance;
      final productsResult = await connector.listProducts().execute();
      final redeemedResult = await connector
          .listRedeemedProducts(userId: user.uid)
          .execute();
      final profileResult = await connector
          .getUserProfile(username: user.uid)
          .execute();
      final scholarshipsResult = await connector.listScholarships().execute();

      final redeemedIds = redeemedResult.data.redeemedProducts
          .map((r) => r.product.id)
          .toSet();
      final unredeemed =
          productsResult.data.products
              .where((p) => p.active && !redeemedIds.contains(p.id))
              .toList()
            ..sort((a, b) => a.cost.compareTo(b.cost));

      final courseId = profileResult.data.users.isNotEmpty
          ? profileResult.data.users.first.course?.id
          : null;
      final matched = courseId == null
          ? <ListScholarshipsScholarships>[]
          : scholarshipsResult.data.scholarships.where((s) {
              return s.courses_via_ScholarshipCourse.any(
                (c) => c.id == courseId,
              );
            }).toList();

      if (!mounted) return;
      setState(() {
        _unredeemedDeals = unredeemed.take(3).toList();
        _matchedScholarships = matched.take(3).toList();
        _isLoadingHomeFeeds = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingHomeFeeds = false);
    }
  }

  Color _scholarshipColor(String rawColor) {
    try {
      return Color(int.parse(rawColor.trim().replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF3e7f3f);
    }
  }

  void _showDiscountDetails(BuildContext context, ListProductsProducts p) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(p.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: buildProductImage(
                p.id,
                size: 110,
                radius: 12,
                fallbackColor: Colors.grey.shade300,
                fallbackChild: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.storeName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.description,
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${p.cost} pts',
              style: const TextStyle(
                color: Color(0xFF3e7f3f),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showScholarshipDetails(
    BuildContext context,
    ListScholarshipsScholarships s,
  ) {
    final scholarshipColor = _scholarshipColor(s.color);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(s.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider: ${s.provider}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scholarshipColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please email us your application letter and school records.',
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact: ${s.email}',
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${s.currency}${s.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: scholarshipColor,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.description,
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = DateFormat('EEEE, MMMM d').format(now);
    final txProvider = Provider.of<TransactionProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final displayName = userProvider.profile?.firstName ?? 'Student';

    final expenses = txProvider.monthlySpent;
    final budget = budgetProvider.budget.amount;
    final available = budget > 0 ? (budget - expenses).clamp(0.0, budget) : 0.0;
    final spentPct = budget > 0 ? (expenses / budget).clamp(0.0, 1.0) : 0.0;
    final recent = txProvider.transactions.take(3).toList();
    final monthTxCount = txProvider.transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .length;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 24),

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
                      color: const Color(0xFF3e7f3f).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: 'Spent this month',
                            value: '€${expenses.toStringAsFixed(2)}',
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Left in budget',
                            value: '€${available.toStringAsFixed(2)}',
                            icon: Icons.savings_outlined,
                          ),
                        ),
                      ],
                    ),
                    if (budget > 0) ...[
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 10),
                      Text(
                        '${(spentPct * 100).toStringAsFixed(0)}% of budget used',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _QuickStatCard(
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFF4ECDC4),
                      label: 'Transactions',
                      value: '$monthTxCount',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStatCard(
                      icon: Icons.trending_down_outlined,
                      color: const Color(0xFFFF6B6B),
                      label: 'Spent today',
                      value:
                          '€${_todaySpend(txProvider.transactions).toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              if (_isLoadingHomeFeeds || _unredeemedDeals.isNotEmpty) ...[
                Text(
                  'Your discounts',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoadingHomeFeeds)
                  Text(
                    'Loading discounts...',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  )
                else
                  ..._unredeemedDeals.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => _showDiscountDetails(context, p),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: buildProductImage(
                                  p.id,
                                  size: 44,
                                  radius: 12,
                                  fallbackColor: Colors.grey.shade300,
                                  fallbackChild: const Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      p.storeName,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.75),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${p.cost} pts',
                                style: const TextStyle(
                                  color: Color(0xFF3e7f3f),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 18),
              ],
              Text(
                'Scholarships for you',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoadingHomeFeeds)
                Text(
                  'Loading scholarships...',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                )
              else if (_matchedScholarships.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'No matched scholarships yet. Set your course in profile.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                )
              else
                ..._matchedScholarships.map((s) {
                  final scholarshipColor = _scholarshipColor(s.color);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _showScholarshipDetails(context, s),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scholarshipColor.withValues(alpha: 0.08),
                          border: Border.all(
                            color: scholarshipColor.withValues(alpha: 0.28),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: scholarshipColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.school_outlined,
                                color: scholarshipColor,
                                size: 22,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.provider,
                                    style: TextStyle(
                                      color: scholarshipColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${s.currency}${s.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: scholarshipColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 10),

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
                  child: Center(
                    child: Text(
                      'No transactions yet.\nAdd one using the Tracker.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
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
                      final cat = catFor(tx.category);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
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
                          DateFormat('MMM d').format(tx.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Text(
                          '-€${tx.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 20)),
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
