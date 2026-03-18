part of 'generated.dart';

class GetUserPointsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  GetUserPointsVariablesBuilder(this._dataConnect, {required this.userId});
  Deserializer<GetUserPointsData> dataDeserializer = (dynamic json) =>
      GetUserPointsData.fromJson(jsonDecode(json));
  Serializer<GetUserPointsVariables> varsSerializer =
      (GetUserPointsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUserPointsData, GetUserPointsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUserPointsData, GetUserPointsVariables> ref() {
    GetUserPointsVariables vars = GetUserPointsVariables(userId: userId);
    return _dataConnect.query(
      "GetUserPoints",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

@immutable
class GetUserPointsPointsBalances {
  final String id;
  final int totalPoints;
  final Timestamp updatedAt;
  GetUserPointsPointsBalances.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']),
      totalPoints = nativeFromJson<int>(json['totalPoints']),
      updatedAt = Timestamp.fromJson(json['updatedAt']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserPointsPointsBalances otherTyped =
        other as GetUserPointsPointsBalances;
    return id == otherTyped.id &&
        totalPoints == otherTyped.totalPoints &&
        updatedAt == otherTyped.updatedAt;
  }

  @override
  int get hashCode =>
      Object.hashAll([id.hashCode, totalPoints.hashCode, updatedAt.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['totalPoints'] = nativeToJson<int>(totalPoints);
    json['updatedAt'] = updatedAt.toJson();
    return json;
  }

  GetUserPointsPointsBalances({
    required this.id,
    required this.totalPoints,
    required this.updatedAt,
  });
}

@immutable
class GetUserPointsData {
  final List<GetUserPointsPointsBalances> pointsBalances;
  GetUserPointsData.fromJson(dynamic json)
    : pointsBalances = (json['pointsBalances'] as List<dynamic>)
          .map((e) => GetUserPointsPointsBalances.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserPointsData otherTyped = other as GetUserPointsData;
    return pointsBalances == otherTyped.pointsBalances;
  }

  @override
  int get hashCode => pointsBalances.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pointsBalances'] = pointsBalances.map((e) => e.toJson()).toList();
    return json;
  }

  GetUserPointsData({required this.pointsBalances});
}

@immutable
class GetUserPointsVariables {
  final String userId;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  GetUserPointsVariables.fromJson(Map<String, dynamic> json)
    : userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserPointsVariables otherTyped = other as GetUserPointsVariables;
    return userId == otherTyped.userId;
  }

  @override
  int get hashCode => userId.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  GetUserPointsVariables({required this.userId});
}
