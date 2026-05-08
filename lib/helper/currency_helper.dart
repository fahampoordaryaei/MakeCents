import 'package:flutter/foundation.dart';

String currency = '€';
int? currencyId;

final ValueNotifier<String> currencyNotifier = ValueNotifier<String>(currency);

void setGlobalCurrency({required String sign, int? id}) {
  currency = sign;
  currencyId = id;
  currencyNotifier.value = sign;
}

String formatMoney(num amount, {int decimals = 2, String? symbol}) {
  final activeSymbol = (symbol == null || symbol.isEmpty) ? currency : symbol;
  return '$activeSymbol${amount.toStringAsFixed(decimals)}';
}
