import 'dart:convert';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dataconnect_generated/generated.dart';

// ---------- GetLoginStatus (query) ----------

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

// ---------- RecordFailedLogin (mutation) ----------

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

class _EmptyData {
  _EmptyData.fromJson(dynamic json);
}

// ---------- ResetLoginAttempts (mutation) ----------

class _ResetLoginAttemptsVars {
  final String username;
  _ResetLoginAttemptsVars({required this.username});

  Map<String, dynamic> toJson() => {'username': nativeToJson<String>(username)};
}

// ---------- Extension on ExampleConnector ----------

extension LoginLockoutConnector on ExampleConnector {
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
