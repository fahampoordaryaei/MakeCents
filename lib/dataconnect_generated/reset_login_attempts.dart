part of 'generated.dart';

class ResetLoginAttemptsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ResetLoginAttemptsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ResetLoginAttemptsData> dataDeserializer = (dynamic json)  => ResetLoginAttemptsData.fromJson(jsonDecode(json));
  Serializer<ResetLoginAttemptsVariables> varsSerializer = (ResetLoginAttemptsVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<ResetLoginAttemptsData, ResetLoginAttemptsVariables>> execute() {
    return ref().execute();
  }

  MutationRef<ResetLoginAttemptsData, ResetLoginAttemptsVariables> ref() {
    ResetLoginAttemptsVariables vars= ResetLoginAttemptsVariables(userId: userId,);
    return _dataConnect.mutation("ResetLoginAttempts", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ResetLoginAttemptsUserUpdate {
  final String userId;
  ResetLoginAttemptsUserUpdate.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ResetLoginAttemptsUserUpdate otherTyped = other as ResetLoginAttemptsUserUpdate;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ResetLoginAttemptsUserUpdate({
    required this.userId,
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
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ResetLoginAttemptsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ResetLoginAttemptsVariables otherTyped = other as ResetLoginAttemptsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ResetLoginAttemptsVariables({
    required this.userId,
  });
}

