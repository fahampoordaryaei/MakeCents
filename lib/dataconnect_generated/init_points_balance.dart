part of 'generated.dart';

class InitPointsBalanceVariablesBuilder {
  String userId;
  int totalPoints;

  final FirebaseDataConnect _dataConnect;
  InitPointsBalanceVariablesBuilder(
    this._dataConnect, {
    required this.userId,
    required this.totalPoints,
  });
  Deserializer<InitPointsBalanceData> dataDeserializer = (dynamic json) =>
      InitPointsBalanceData.fromJson(jsonDecode(json));
  Serializer<InitPointsBalanceVariables> varsSerializer =
      (InitPointsBalanceVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<InitPointsBalanceData, InitPointsBalanceVariables>>
  execute() {
    return ref().execute();
  }

  MutationRef<InitPointsBalanceData, InitPointsBalanceVariables> ref() {
    InitPointsBalanceVariables vars = InitPointsBalanceVariables(
      userId: userId,
      totalPoints: totalPoints,
    );
    return _dataConnect.mutation(
      "InitPointsBalance",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

@immutable
class InitPointsBalancePointsBalanceInsert {
  final String id;
  InitPointsBalancePointsBalanceInsert.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final InitPointsBalancePointsBalanceInsert otherTyped =
        other as InitPointsBalancePointsBalanceInsert;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  InitPointsBalancePointsBalanceInsert({required this.id});
}

@immutable
class InitPointsBalanceData {
  final InitPointsBalancePointsBalanceInsert pointsBalance_insert;
  InitPointsBalanceData.fromJson(dynamic json)
    : pointsBalance_insert = InitPointsBalancePointsBalanceInsert.fromJson(
        json['pointsBalance_insert'],
      );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final InitPointsBalanceData otherTyped = other as InitPointsBalanceData;
    return pointsBalance_insert == otherTyped.pointsBalance_insert;
  }

  @override
  int get hashCode => pointsBalance_insert.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pointsBalance_insert'] = pointsBalance_insert.toJson();
    return json;
  }

  InitPointsBalanceData({required this.pointsBalance_insert});
}

@immutable
class InitPointsBalanceVariables {
  final String userId;
  final int totalPoints;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  InitPointsBalanceVariables.fromJson(Map<String, dynamic> json)
    : userId = nativeFromJson<String>(json['userId']),
      totalPoints = nativeFromJson<int>(json['totalPoints']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final InitPointsBalanceVariables otherTyped =
        other as InitPointsBalanceVariables;
    return userId == otherTyped.userId && totalPoints == otherTyped.totalPoints;
  }

  @override
  int get hashCode => Object.hashAll([userId.hashCode, totalPoints.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['totalPoints'] = nativeToJson<int>(totalPoints);
    return json;
  }

  InitPointsBalanceVariables({required this.userId, required this.totalPoints});
}
