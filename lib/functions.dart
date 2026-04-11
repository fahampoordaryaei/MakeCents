import 'dart:convert';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.id, this.name, this.icon, this.color);
}

List<ExpenseCategory> dynamicCategories = [];
String currency = '€';

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

class GetLoginStatusUsers {
  final String username;
  final int failedAttempts;
  final DateTime? lockedUntil;

  GetLoginStatusUsers.fromJson(dynamic json)
    : username = nativeFromJson<String>(json['username']),
      failedAttempts = nativeFromJson<int>(json['failedAttempts']),
      lockedUntil = json['lockedUntil'] == null
          ? null
          : DateTime.parse(json['lockedUntil']);
}

class GetLoginStatusData {
  final List<GetLoginStatusUsers> users;

  GetLoginStatusData.fromJson(dynamic json)
    : users = (json['users'] as List<dynamic>)
          .map((e) => GetLoginStatusUsers.fromJson(e))
          .toList();
}

class _GetLoginStatusVars {
  final String email;
  _GetLoginStatusVars({required this.email});
  Map<String, dynamic> toJson() => {'email': nativeToJson<String>(email)};
}

class _RecordFailedLoginVars {
  final String username;
  final int failedAttempts;
  final DateTime? lockedUntil;

  _RecordFailedLoginVars({
    required this.username,
    required this.failedAttempts,
    this.lockedUntil,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'username': nativeToJson<String>(username),
      'failedAttempts': nativeToJson<int>(failedAttempts),
    };
    if (lockedUntil != null) {
      json['lockedUntil'] = lockedUntil!.toIso8601String();
    }
    return json;
  }
}

class _ResetLoginAttemptsVars {
  final String username;
  _ResetLoginAttemptsVars({required this.username});
  Map<String, dynamic> toJson() => {'username': nativeToJson<String>(username)};
}

class _EmptyData {
  _EmptyData.fromJson(dynamic json);
}

extension LoginLockoutExtension on ExampleConnector {
  Future<GetLoginStatusData> getLoginStatus({required String email}) async {
    final result = await dataConnect
        .query(
          "GetLoginStatus",
          (dynamic json) => GetLoginStatusData.fromJson(jsonDecode(json)),
          (_GetLoginStatusVars vars) => jsonEncode(vars.toJson()),
          _GetLoginStatusVars(email: email),
        )
        .execute();
    return result.data;
  }

  Future<void> recordFailedLogin({
    required String username,
    required int failedAttempts,
    DateTime? lockedUntil,
  }) async {
    await dataConnect
        .mutation(
          "RecordFailedLogin",
          (dynamic json) => _EmptyData.fromJson(json),
          (_RecordFailedLoginVars vars) => jsonEncode(vars.toJson()),
          _RecordFailedLoginVars(
            username: username,
            failedAttempts: failedAttempts,
            lockedUntil: lockedUntil,
          ),
        )
        .execute();
  }

  Future<void> resetLoginAttempts({required String username}) async {
    await dataConnect
        .mutation(
          "ResetLoginAttempts",
          (dynamic json) => _EmptyData.fromJson(json),
          (_ResetLoginAttemptsVars vars) => jsonEncode(vars.toJson()),
          _ResetLoginAttemptsVars(username: username),
        )
        .execute();
  }
}
