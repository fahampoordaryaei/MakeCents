part of 'generated.dart';

class ResetLoginAttemptsVariablesBuilder {
  String username;

  final FirebaseDataConnect _dataConnect;
  ResetLoginAttemptsVariablesBuilder(this._dataConnect, {required  this.username,});
  Deserializer<ResetLoginAttemptsData> dataDeserializer = (dynamic json)  => ResetLoginAttemptsData.fromJson(jsonDecode(json));
  Serializer<ResetLoginAttemptsVariables> varsSerializer = (ResetLoginAttemptsVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<ResetLoginAttemptsData, ResetLoginAttemptsVariables>> execute() {
    return ref().execute();
  }

  MutationRef<ResetLoginAttemptsData, ResetLoginAttemptsVariables> ref() {
    ResetLoginAttemptsVariables vars= ResetLoginAttemptsVariables(username: username,);
    return _dataConnect.mutation("ResetLoginAttempts", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ResetLoginAttemptsUserUpdate {
  final String username;
  ResetLoginAttemptsUserUpdate.fromJson(dynamic json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ResetLoginAttemptsUserUpdate otherTyped = other as ResetLoginAttemptsUserUpdate;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  ResetLoginAttemptsUserUpdate({
    required this.username,
  });
}

@immutable
class ResetLoginAttemptsData {
  final ResetLoginAttemptsUserUpdate? user_update;
  ResetLoginAttemptsData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : ResetLoginAttemptsUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ResetLoginAttemptsData otherTyped = other as ResetLoginAttemptsData;
    return user_update == otherTyped.user_update;
    
  }
  @override
  int get hashCode => user_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    return json;
  }

  ResetLoginAttemptsData({
    this.user_update,
  });
}

@immutable
class ResetLoginAttemptsVariables {
  final String username;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ResetLoginAttemptsVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ResetLoginAttemptsVariables otherTyped = other as ResetLoginAttemptsVariables;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  ResetLoginAttemptsVariables({
    required this.username,
  });
}

