part of 'generated.dart';

class UpdateUserAllowOverbudgetVariablesBuilder {
  String userId;
  bool allowOverbudget;

  final FirebaseDataConnect _dataConnect;
  UpdateUserAllowOverbudgetVariablesBuilder(this._dataConnect, {required  this.userId,required  this.allowOverbudget,});
  Deserializer<UpdateUserAllowOverbudgetData> dataDeserializer = (dynamic json)  => UpdateUserAllowOverbudgetData.fromJson(jsonDecode(json));
  Serializer<UpdateUserAllowOverbudgetVariables> varsSerializer = (UpdateUserAllowOverbudgetVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateUserAllowOverbudgetData, UpdateUserAllowOverbudgetVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateUserAllowOverbudgetData, UpdateUserAllowOverbudgetVariables> ref() {
    UpdateUserAllowOverbudgetVariables vars= UpdateUserAllowOverbudgetVariables(userId: userId,allowOverbudget: allowOverbudget,);
    return _dataConnect.mutation("UpdateUserAllowOverbudget", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateUserAllowOverbudgetUserUpdate {
  final String userId;
  UpdateUserAllowOverbudgetUserUpdate.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserAllowOverbudgetUserUpdate otherTyped = other as UpdateUserAllowOverbudgetUserUpdate;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  UpdateUserAllowOverbudgetUserUpdate({
    required this.userId,
  });
}

@immutable
class UpdateUserAllowOverbudgetData {
  final UpdateUserAllowOverbudgetUserUpdate? user_update;
  UpdateUserAllowOverbudgetData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateUserAllowOverbudgetUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserAllowOverbudgetData otherTyped = other as UpdateUserAllowOverbudgetData;
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

  UpdateUserAllowOverbudgetData({
    this.user_update,
  });
}

@immutable
class UpdateUserAllowOverbudgetVariables {
  final String userId;
  final bool allowOverbudget;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateUserAllowOverbudgetVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  allowOverbudget = nativeFromJson<bool>(json['allowOverbudget']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserAllowOverbudgetVariables otherTyped = other as UpdateUserAllowOverbudgetVariables;
    return userId == otherTyped.userId && 
    allowOverbudget == otherTyped.allowOverbudget;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, allowOverbudget.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['allowOverbudget'] = nativeToJson<bool>(allowOverbudget);
    return json;
  }

  UpdateUserAllowOverbudgetVariables({
    required this.userId,
    required this.allowOverbudget,
  });
}

