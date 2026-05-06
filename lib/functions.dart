import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'dataconnect_generated/generated.dart';
import 'scholarship_application_page.dart';

typedef UploadResult = ({String path, String filename});

Future<UploadResult> uploadAttachment(File file, {String? displayName}) async {
  final uuid = const Uuid().v4();
  final raw = displayName ?? file.path.replaceAll(r'\', '/').split('/').last;
  var filename = raw.replaceAll(RegExp(r'[/\\]'), '_').trim();
  if (filename.isEmpty) filename = 'attachment';

  final path = 'Documents/$uuid/$filename';
  await FirebaseStorage.instance.ref(path).putFile(file);
  return (path: path, filename: filename);
}

Future<void> sendUserEmailVerification(User user) async {
  final projectId = Firebase.app().options.projectId;
  final continueUrl = Uri.https('$projectId.firebaseapp.com', '/').toString();
  await user.sendEmailVerification(
    ActionCodeSettings(url: continueUrl, handleCodeInApp: false),
  );
}

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

Future<void> showScholarshipApplyDialog(
  BuildContext context, {
  String? scholarshipId,
  required String title,
  required String provider,
  required double amount,
  required String currency,
  required String description,
  required Color brandColor,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ScholarshipApplicationPage(
        scholarshipId: scholarshipId,
        title: title,
        provider: provider,
        amount: amount,
        currency: currency,
        description: description,
        brandColor: brandColor,
      ),
    ),
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
            fontSize: 14,
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF3e7f3f),
                  ),
                ),
              ],
            ),
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
                            fontSize: 20,
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
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 18),
                      ),
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
                                : const Text(
                                    'Redeem',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          )
                        : FilledButton(
                            onPressed: null,
                            child: Text(
                              'Need $need pts',
                              style: TextStyle(fontSize: 18),
                            ),
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
                          color: _msgErr
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFF3e7f3f),
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

ExpenseCategory categoryFor(String name) {
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
    case 'directions_car':
      return Icons.directions_car;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'favorite':
      return Icons.favorite;
    case 'institution':
    case 'school':
      return Icons.school;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'receipt':
      return Icons.receipt;
    case 'receipt_long':
      return Icons.receipt_long;
    case 'movie':
      return Icons.movie;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'flight':
      return Icons.flight;
    default:
      return Icons.more_horiz;
  }
}

// I replaced hardcoded colors with database values
Color parseColorHex(String colorHex) {
  final h = colorHex.trim();
  if (h.isEmpty) return Colors.grey;
  try {
    if (h.startsWith('0x') || h.startsWith('0X')) {
      return Color(int.parse(h));
    }
    return Color(int.parse(h.replaceFirst('#', '0xFF')));
  } catch (_) {
    return Colors.grey;
  }
}

void setGlobalExpenseCategoriesFromRows(
  List<ListExpenseCategoriesExpenseCategories> rows,
) {
  dynamicCategories = rows
      .map(
        (c) => ExpenseCategory(
          c.id,
          c.name,
          getIconByName(c.iconName),
          parseColorHex(c.colorHex),
        ),
      )
      .toList();
}

enum AppAlertLevel { warning, error, success }

Future<void> popupAlert(
  BuildContext context, {
  required String message,
  required AppAlertLevel level,
}) async {
  if (!context.mounted) return;

  final icon = level == AppAlertLevel.warning
      ? Icons.warning_amber_rounded
      : level == AppAlertLevel.error
      ? Icons.error_rounded
      : Icons.check_circle_rounded;

  final bg = level == AppAlertLevel.warning
      ? const Color(0xFFFFF3E0)
      : level == AppAlertLevel.error
      ? Theme.of(context).colorScheme.errorContainer
      : const Color(0xFFE8F5E9);

  final fg = level == AppAlertLevel.warning
      ? const Color(0xFFEF6C00)
      : level == AppAlertLevel.error
      ? Theme.of(context).colorScheme.onErrorContainer
      : const Color(0xFF2E7D32);

  var visible = true;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 20,
      right: 20,
      bottom: MediaQuery.of(ctx).padding.bottom + 90,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        onEnd: () {
          if (!visible) entry.remove();
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    visible = false;
    entry.markNeedsBuild();
  });
}
