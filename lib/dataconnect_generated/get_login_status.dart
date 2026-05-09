part of 'generated.dart';

class GetLoginStatusVariablesBuilder {
  String email;

  final FirebaseDataConnect _dataConnect;
  GetLoginStatusVariablesBuilder(this._dataConnect, {required  this.email,});
  Deserializer<GetLoginStatusData> dataDeserializer = (dynamic json)  => GetLoginStatusData.fromJson(jsonDecode(json));
  Serializer<GetLoginStatusVariables> varsSerializer = (GetLoginStatusVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetLoginStatusData, GetLoginStatusVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetLoginStatusData, GetLoginStatusVariables> ref() {
    GetLoginStatusVariables vars= GetLoginStatusVariables(email: email,);
    return _dataConnect.query("GetLoginStatus", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetLoginStatusUsers {
  final String userId;
  final int failedAttempts;
  final Timestamp? lockedUntil;
  GetLoginStatusUsers.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']),
  failedAttempts = nativeFromJson<int>(json['failedAttempts']),
  lockedUntil = json['lockedUntil'] == null ? null : Timestamp.fromJson(json['lockedUntil']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoginStatusUsers otherTyped = other as GetLoginStatusUsers;
    return userId == otherTyped.userId && 
    failedAttempts == otherTyped.failedAttempts && 
    lockedUntil == otherTyped.lockedUntil;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, failedAttempts.hashCode, lockedUntil.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['failedAttempts'] = nativeToJson<int>(failedAttempts);
    if (lockedUntil != null) {
      json['lockedUntil'] = lockedUntil!.toJson();
    }
    return json;
  }

  GetLoginStatusUsers({
    required this.userId,
    required this.failedAttempts,
    this.lockedUntil,
  });
}

@immutable
class GetLoginStatusData {
  final List<GetLoginStatusUsers> users;
  GetLoginStatusData.fromJson(dynamic json):
  
  users = (json['users'] as List<dynamic>)
        .map((e) => GetLoginStatusUsers.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoginStatusData otherTyped = other as GetLoginStatusData;
    return users == otherTyped.users;
    
  }
  @override
  int get hashCode => users.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['users'] = users.map((e) => e.toJson()).toList();
    return json;
  }

  GetLoginStatusData({
    required this.users,
  });
}

@immutable
class GetLoginStatusVariables {
  final String email;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetLoginStatusVariables.fromJson(Map<String, dynamic> json):
  
  email = nativeFromJson<String>(json['email']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetLoginStatusVariables otherTyped = other as GetLoginStatusVariables;
    return email == otherTyped.email;
    
  }
  @override
  int get hashCode => email.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['email'] = nativeToJson<String>(email);
    return json;
  }

  GetLoginStatusVariables({
    required this.email,
  });
}

