import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.id, this.name, this.icon, this.color);
}

List<ExpenseCategory> dynamicCategories = [];

ExpenseCategory catFor(String name) => dynamicCategories.firstWhere(
  (c) => c.name == name,
  orElse: () => dynamicCategories.isNotEmpty
      ? dynamicCategories.last
      : const ExpenseCategory('', 'Other', Icons.more_horiz, Colors.grey),
);

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
