import 'package:flutter/material.dart';
import 'package:makecents/dataconnect_generated/generated.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category(this.id, this.name, this.icon, this.color);
}

List<Category> categories = [];

Category categoryFor(String name) {
  for (final c in categories) {
    if (c.name == name) return c;
  }
  return const Category('', 'Other', Icons.more_horiz, Colors.grey);
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

// I replaced hardcoded colors with database values.
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

void setCategories(List<ListCategoriesCategories> rows) {
  categories = rows
      .map(
        (c) => Category(
          c.id,
          c.name,
          getIconByName(c.iconName),
          parseColorHex(c.colorHex),
        ),
      )
      .toList();

  categories.sort((a, b) {
    final aOther = a.name.toLowerCase() == 'other';
    final bOther = b.name.toLowerCase() == 'other';
    if (aOther == bOther) return 0;
    return aOther ? 1 : -1;
  });
}
