part of 'generated.dart';

class UpdatePointsBalanceVariablesBuilder {
  String id;
  int totalPoints;

  final FirebaseDataConnect _dataConnect;
  UpdatePointsBalanceVariablesBuilder(
    this._dataConnect, {
    required this.id,
    required this.totalPoints,
  });
  Deserializer<UpdatePointsBalanceData> dataDeserializer = (dynamic json) =>
      UpdatePointsBalanceData.fromJson(jsonDecode(json));
  Serializer<UpdatePointsBalanceVariables> varsSerializer =
      (UpdatePointsBalanceVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdatePointsBalanceData, UpdatePointsBalanceVariables>>
  execute() {
    return ref().execute();
  }

  MutationRef<UpdatePointsBalanceData, UpdatePointsBalanceVariables> ref() {
    UpdatePointsBalanceVariables vars = UpdatePointsBalanceVariables(
      id: id,
      totalPoints: totalPoints,
    );
    return _dataConnect.mutation(
      "UpdatePointsBalance",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

@immutable
class UpdatePointsBalancePointsBalanceUpdate {
  final String id;
  UpdatePointsBalancePointsBalanceUpdate.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdatePointsBalancePointsBalanceUpdate otherTyped =
        other as UpdatePointsBalancePointsBalanceUpdate;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdatePointsBalancePointsBalanceUpdate({required this.id});
}

@immutable
class UpdatePointsBalanceData {
  final UpdatePointsBalancePointsBalanceUpdate? pointsBalance_update;
  UpdatePointsBalanceData.fromJson(dynamic json)
    : pointsBalance_update = json['pointsBalance_update'] == null
          ? null
          : UpdatePointsBalancePointsBalanceUpdate.fromJson(
              json['pointsBalance_update'],
            );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdatePointsBalanceData otherTyped = other as UpdatePointsBalanceData;
    return pointsBalance_update == otherTyped.pointsBalance_update;
  }

  @override
  int get hashCode => pointsBalance_update.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (pointsBalance_update != null) {
      json['pointsBalance_update'] = pointsBalance_update!.toJson();
    }
    return json;
  }

  UpdatePointsBalanceData({this.pointsBalance_update});
}

@immutable
class UpdatePointsBalanceVariables {
  final String id;
  final int totalPoints;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  UpdatePointsBalanceVariables.fromJson(Map<String, dynamic> json)
    : id = nativeFromJson<String>(json['id']),
      totalPoints = nativeFromJson<int>(json['totalPoints']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final UpdatePointsBalanceVariables otherTyped =
        other as UpdatePointsBalanceVariables;
    return id == otherTyped.id && totalPoints == otherTyped.totalPoints;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, totalPoints.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['totalPoints'] = nativeToJson<int>(totalPoints);
    return json;
  }

  UpdatePointsBalanceVariables({required this.id, required this.totalPoints});
}
