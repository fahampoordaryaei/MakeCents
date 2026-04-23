import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';

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
