import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  String? _redeemingProductId;
  List<ListProductsProducts> _products = const [];
  Map<String, _RedeemedProductInfo> _redeemedByProductId = const {};

  @override
  void initState() {
    super.initState();
    _loadCloudPoints();
    _loadProductsAndRedemptions();
  }

  Future<void> _loadCloudPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingPoints = false);
      return;
    }

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingProducts = false);
      return;
    }

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

  Future<_RedeemResult> _redeemProduct(ListProductsProducts product) async {
    setState(() => _redeemingProductId = product.id);
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('redeemProduct');
      final response = await callable
          .call(<String, dynamic>{'productId': product.id})
          .timeout(const Duration(seconds: 20));

      final data = Map<String, dynamic>.from(response.data as Map);
      final code = (data['code'] as String?) ?? '';
      final remainingPoints = (data['remainingPoints'] as num?)?.toInt();
      if (mounted && remainingPoints != null) {
        setState(() => _points = remainingPoints);
      }
      await _refreshRedeemData();

      return _RedeemResult(
        text: code.isNotEmpty ? code : 'REDEEMED',
        isError: false,
      );
    } on FirebaseFunctionsException catch (e) {
      final mapped = switch (e.code) {
        'unauthenticated' => 'Please sign in and try again.',
        'not-found' => 'This product could not be found.',
        'failed-precondition' =>
          e.message ?? 'This product cannot be redeemed.',
        'aborted' =>
          e.message ?? 'Could not generate a discount code. Try again.',
        _ => e.message ?? 'Could not redeem product right now.',
      };
      return _RedeemResult(text: mapped, isError: true);
    } on TimeoutException {
      return const _RedeemResult(
        text: 'Redeem request timed out. Please retry.',
        isError: true,
      );
    } catch (_) {
      return const _RedeemResult(
        text: 'Could not redeem product.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _redeemingProductId = null);
    }
  }

  Future<void> _showProductDetails(
    BuildContext context,
    ListProductsProducts product,
  ) async {
    String? inlineMessage;
    bool inlineIsError = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final points = _points ?? 0;
            final redeemed = _redeemedByProductId[product.id];
            final isRedeemed = redeemed != null;
            final redeeming = _redeemingProductId == product.id;
            final needed = (product.cost - points).clamp(0, 999999);

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProductImage(product.id, size: 110, radius: 14),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.storeName,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3e7f3f,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${product.cost} pts',
                                    style: const TextStyle(
                                      color: Color(0xFF3e7f3f),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: redeeming
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: isRedeemed
                                ? FilledButton(
                                    onPressed: null,
                                    child: const Text('Redeemed'),
                                  )
                                : points >= product.cost
                                ? FilledButton(
                                    onPressed: redeeming
                                        ? null
                                        : () async {
                                            setDialogState(() {
                                              inlineMessage = null;
                                              inlineIsError = false;
                                            });
                                            final result = await _redeemProduct(
                                              product,
                                            );
                                            if (!mounted) return;
                                            setDialogState(() {
                                              inlineMessage = result.text;
                                              inlineIsError = result.isError;
                                            });
                                          },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF3e7f3f),
                                      foregroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : null,
                                    ),
                                    child: redeeming
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Redeem'),
                                  )
                                : FilledButton(
                                    onPressed: null,
                                    child: Text('Need $needed pts'),
                                  ),
                          ),
                        ],
                      ),
                      if (inlineMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.38),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inlineIsError ? 'Status' : 'Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: inlineIsError
                                      ? Colors.red
                                      : Color(0xFF3e7f3f),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SelectableText(
                                inlineMessage!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
                fontSize: 16,
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
                            size: 36,
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
                fontSize: 18,
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
                'Stay under budget (monthly)',
                '+100 pts',
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
                            fontSize: 16,
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
                fontSize: 18,
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
                  fontSize: 16,
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
                                    fontSize: 16,
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
                                    fontSize: 16,
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
                                      fontSize: 16,
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
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!isRedeemed)
                                OutlinedButton(
                                  onPressed: () =>
                                      _showProductDetails(context, p),
                                  child: const Text('View'),
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

class _RedeemResult {
  final String text;
  final bool isError;

  const _RedeemResult({required this.text, required this.isError});
}
