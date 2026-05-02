import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dataconnect_generated/generated.dart';

Future<List<ListGlobalScholarshipsScholarships>> fetchScholarshipsForLocation(
  ExampleConnector connector, {
  required int? countryId,
}) async {
  if (countryId != null) {
    final rows =
        (await connector
                .getContinentsForCountry(countryId: countryId)
                .execute())
            .data
            .countryContinents;
    if (rows.isNotEmpty) {
      final r = await connector
          .listScholarshipsForUser(
            countryId: countryId,
            continentId: rows.first.continent.id,
          )
          .execute();
      return [
        for (final s in r.data.scholarships)
          ListGlobalScholarshipsScholarships.fromJson(s.toJson()),
      ];
    }
  }
  final r = await connector.listGlobalScholarships().execute();
  return r.data.scholarships;
}

(String text, Color color) scholarshipRegion(
  ListGlobalScholarshipsScholarships s,
) {
  final c = s.country;
  if (c != null) {
    final t = c.name.trim();
    if (t.isNotEmpty) return (t.toUpperCase(), const Color(0xFF00796B));
  }
  final k = s.continent;
  if (k != null) {
    final t = k.name.trim();
    if (t.isNotEmpty) return (t.toUpperCase(), const Color(0xFF7B1FA2));
  }
  return ('GLOBAL', const Color(0xFF1565C0));
}

/// Same scholarship detail + apply flow as the Scholarships tab.
Future<void> showScholarshipApplyDialog(
  BuildContext context, {
  required String title,
  required String provider,
  required String email,
  required double amount,
  required String currency,
  required String description,
  required Color brandColor,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final onSurface = Theme.of(dialogContext).colorScheme.onSurface;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider: $provider',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: brandColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: $currency${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: brandColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.85),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please email us your application letter and records from your institution.',
              style: TextStyle(
                fontSize: 18,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close', style: TextStyle(fontSize: 18)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: brandColor),
            onPressed: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: email,
                queryParameters: {
                  'subject': 'Scholarship Application - $title',
                  'body':
                      'Please email us your application letter and records from your institution.',
                },
              );
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open your email app.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Open Email', style: TextStyle(fontSize: 18)),
          ),
        ],
      );
    },
  );
}

Widget scholarshipRegionLabel(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.place, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

typedef _RedeemR = ({String text, bool err, int? pts});

Future<_RedeemR> _redeemProductCall(String productId) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('redeemProduct');
    final response = await callable
        .call(<String, dynamic>{'productId': productId})
        .timeout(const Duration(seconds: 20));
    final data = Map<String, dynamic>.from(response.data as Map);
    final code = (data['code'] as String?) ?? '';
    final remainingPoints = (data['remainingPoints'] as num?)?.toInt();
    return (
      text: code.isNotEmpty ? code : 'REDEEMED',
      err: false,
      pts: remainingPoints,
    );
  } on FirebaseFunctionsException catch (e) {
    final mapped = switch (e.code) {
      'unauthenticated' => 'Please sign in and try again.',
      'not-found' => 'This product could not be found.',
      'failed-precondition' => e.message ?? 'This product cannot be redeemed.',
      'aborted' =>
        e.message ?? 'Could not generate a discount code. Try again.',
      _ => e.message ?? 'Could not redeem product right now.',
    };
    return (text: mapped, err: true, pts: null);
  } on TimeoutException {
    return (
      text: 'Redeem request timed out. Please retry.',
      err: true,
      pts: null,
    );
  } catch (_) {
    return (text: 'Could not redeem product.', err: true, pts: null);
  }
}

/// Product preview + redeem (shared by Home and Points).
Future<void> showProductRedeemDialog(
  BuildContext context,
  ListProductsProducts product,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ProductRedeemBody(product: product),
  );
}

class _ProductRedeemBody extends StatefulWidget {
  const _ProductRedeemBody({required this.product});
  final ListProductsProducts product;

  @override
  State<_ProductRedeemBody> createState() => _ProductRedeemBodyState();
}

class _ProductRedeemBodyState extends State<_ProductRedeemBody> {
  bool _loading = true;
  int? _points;
  final Map<String, String> _codes = {};
  bool _busy = false;
  String? _msg;
  bool _msgErr = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final c = ExampleConnector.instance;
      final pr = await c.getUserPoints(userId: u.uid).execute();
      final rr = await c.listRedeemedProducts(userId: u.uid).execute();
      int? pts;
      if (pr.data.pointsBalances.isNotEmpty) {
        pts = pr.data.pointsBalances.first.totalPoints;
      }
      if (!mounted) return;
      setState(() {
        _points = pts;
        _codes
          ..clear()
          ..addAll({
            for (final r in rr.data.redeemedProducts) r.product.id: r.code,
          });
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _redeem() async {
    setState(() {
      _msg = null;
      _msgErr = false;
      _busy = true;
    });
    final r = await _redeemProductCall(widget.product.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _msg = r.text;
      _msgErr = r.err;
      if (!r.err) {
        if (r.pts != null) _points = r.pts;
        _codes[widget.product.id] = r.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF3e7f3f)),
          ),
        ),
      );
    }
    final p = widget.product;
    final pts = _points ?? 0;
    final redeemed = _codes.containsKey(p.id);
    final need = (p.cost - pts).clamp(0, 999999);
    final fg = Theme.of(context).colorScheme.onSurface;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  buildProductImage(p.id, size: 110, radius: 14),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.storeName,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
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
                            '${p.cost} pts',
                            style: const TextStyle(
                              color: Color(0xFF3e7f3f),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(p.description, style: TextStyle(fontSize: 18, color: fg)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: redeemed
                        ? FilledButton(
                            onPressed: null,
                            child: const Text('Redeemed'),
                          )
                        : pts >= p.cost
                        ? FilledButton(
                            onPressed: _busy ? null : _redeem,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF3e7f3f),
                              foregroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : null,
                            ),
                            child: _busy
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
                            child: Text('Need $need pts'),
                          ),
                  ),
                ],
              ),
              if (_msg != null) ...[
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
                        _msgErr ? 'Status' : 'Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _msgErr ? Colors.red : const Color(0xFF3e7f3f),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        _msg!,
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
  }
}

typedef CurrenciesList = ListCurrenciesCurrencies;

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.id, this.name, this.icon, this.color);
}

List<ExpenseCategory> dynamicCategories = [];

String currency = '€';
int? currencyId;
final ValueNotifier<String> currencyNotifier = ValueNotifier<String>(currency);

void setGlobalCurrency({required String sign, int? id}) {
  currency = sign;
  currencyId = id;
  if (currencyNotifier.value != sign) {
    currencyNotifier.value = sign;
  }
}

ExpenseCategory catFor(String name) {
  for (final c in dynamicCategories) {
    if (c.name == name) return c;
  }
  return const ExpenseCategory('', 'Other', Icons.more_horiz, Colors.grey);
}

bool passwordCriteria(String pass) {
  return pass.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(pass) &&
      RegExp(r'[a-z]').hasMatch(pass) &&
      RegExp(r'[0-9]').hasMatch(pass) &&
      RegExp(r'[^a-zA-Z0-9\s]').hasMatch(pass);
}

String formatMoney(num amount, {int decimals = 2, String? symbol}) {
  final activeSymbol = (symbol == null || symbol.isEmpty) ? currency : symbol;
  return '$activeSymbol${amount.toStringAsFixed(decimals)}';
}

Widget buildProductImage(
  String id, {
  required double size,
  required double radius,
  Color? fallbackColor,
  Widget? fallbackChild,
}) {
  final imageId = id.replaceAll('-', '');
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/products/$imageId.jpg',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: fallbackColor ?? Colors.grey.withValues(alpha: 0.2),
        child: fallbackChild,
      ),
    ),
  );
}

IconData getIconByName(String name) {
  switch (name) {
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'favorite':
      return Icons.favorite;
    case 'institution':
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
