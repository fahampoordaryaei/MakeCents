import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});
  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  int? _points;
  bool _isLoadingPoints = true;
  bool _isLoadingProducts = true;
  List<ListProductsProducts> _products = const [];
  Map<String, _RedeemedProductInfo> _redeemedByProductId = const {};

  @override
  void initState() {
    super.initState();
    _loadCloudPoints();
    _loadProductsAndRedemptions();
  }

  Future<void> _loadCloudPoints() async {
    final user = FirebaseAuth.instance.currentUser!;

    try {
      final result = await ExampleConnector.instance
          .getUserPoints(userId: user.uid)
          .execute();

      if (result.data.pointsBalances.isNotEmpty) {
        _points = result.data.pointsBalances.first.totalPoints;
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingPoints = false);
    }
  }

  Future<void> _loadProductsAndRedemptions() async {
    final user = FirebaseAuth.instance.currentUser!;

    try {
      final productsResult = await ExampleConnector.instance
          .listProducts()
          .execute();
      final redeemedResult = await ExampleConnector.instance
          .listRedeemedProducts(userId: user.uid)
          .execute();

      final redeemedMap = <String, _RedeemedProductInfo>{
        for (final r in redeemedResult.data.redeemedProducts)
          r.product.id: _RedeemedProductInfo(code: r.code),
      };

      if (!mounted) return;
      setState(() {
        _products = productsResult.data.products;
        _redeemedByProductId = redeemedMap;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _refreshRedeemData() async {
    await Future.wait([_loadCloudPoints(), _loadProductsAndRedemptions()]);
  }

  Future<void> _showProductDetails(
    BuildContext context,
    ListProductsProducts product,
  ) async {
    await showProductRedeemDialog(context, product);
    if (mounted) await _refreshRedeemData();
  }

  List<ListProductsProducts> _sortedProducts() {
    final items = [..._products];
    items.sort((a, b) {
      final aRedeemed = _redeemedByProductId.containsKey(a.id);
      final bRedeemed = _redeemedByProductId.containsKey(b.id);
      if (aRedeemed != bRedeemed) return aRedeemed ? 1 : -1;
      return a.cost.compareTo(b.cost);
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final points = _points ?? 0;
    final products = _sortedProducts();
    final bp = Provider.of<BudgetProvider>(context);
    final budgetRewardLabel = bp.isWeekly
        ? 'Within budget (week)'
        : 'Within budget (month)';
    final budgetRewardPts = bp.isWeekly ? '+25 pts' : '+100 pts';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Points',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Earn points by tracking your spending',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.85),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAA96DA), Color(0xFFFC5185)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAA96DA).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _isLoadingPoints
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 48,
                          ),
                          Text(
                            '$points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Total points',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ways to earn points',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              (
                'Log an expense',
                '+10 pts',
                Icons.add_circle_outline,
                const Color(0xFF4ECDC4),
              ),
              (
                budgetRewardLabel,
                budgetRewardPts,
                Icons.savings_outlined,
                const Color(0xFF3e7f3f),
              ),
            ].map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: e.$4.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(e.$3, color: e.$4, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          e.$1,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: e.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e.$2,
                          style: TextStyle(
                            color: e.$4,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Redeem discounts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingProducts)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
                ),
              )
            else if (products.isEmpty)
              Text(
                'No products available right now.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.85),
                  fontSize: 18,
                ),
              )
            else
              ...products.map((p) {
                final redeemed = _redeemedByProductId[p.id];
                final isRedeemed = redeemed != null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _showProductDetails(context, p),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProductImage(p.id, size: 72, radius: 12),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  p.storeName,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (isRedeemed) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Code: ${redeemed.code}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3e7f3f),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF3e7f3f,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${p.cost} pts',
                                  style: const TextStyle(
                                    color: Color(0xFF3e7f3f),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!isRedeemed)
                                OutlinedButton(
                                  onPressed: () =>
                                      _showProductDetails(context, p),
                                  child: const Text(
                                    'View',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _RedeemedProductInfo {
  final String code;

  const _RedeemedProductInfo({required this.code});
}
