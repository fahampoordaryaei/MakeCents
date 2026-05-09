String currency = '€';
int? currencyId;

void setGlobalCurrency({required String sign, int? id}) {
  currency = sign;
  currencyId = id;
}

String formatMoney(num amount, {int decimals = 2, String? symbol}) {
  final activeSymbol = (symbol == null || symbol.isEmpty) ? currency : symbol;
  return '$activeSymbol${amount.toStringAsFixed(decimals)}';
}
