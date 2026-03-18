part of 'generated.dart';

class DeleteUserProfileVariablesBuilder {
  String username;

  final FirebaseDataConnect _dataConnect;
  DeleteUserProfileVariablesBuilder(this._dataConnect, {required  this.username,});
  Deserializer<DeleteUserProfileData> dataDeserializer = (dynamic json)  => DeleteUserProfileData.fromJson(jsonDecode(json));
  Serializer<DeleteUserProfileVariables> varsSerializer = (DeleteUserProfileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteUserProfileData, DeleteUserProfileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteUserProfileData, DeleteUserProfileVariables> ref() {
    DeleteUserProfileVariables vars= DeleteUserProfileVariables(username: username,);
    return _dataConnect.mutation("DeleteUserProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteUserProfileUserDelete {
  final String username;
  DeleteUserProfileUserDelete.fromJson(dynamic json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteUserProfileUserDelete otherTyped = other as DeleteUserProfileUserDelete;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  DeleteUserProfileUserDelete({
    required this.username,
  });
}

@immutable
class DeleteUserProfileData {
  final DeleteUserProfileUserDelete? user_delete;
  DeleteUserProfileData.fromJson(dynamic json):
  
  user_delete = json['user_delete'] == null ? null : DeleteUserProfileUserDelete.fromJson(json['user_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteUserProfileData otherTyped = other as DeleteUserProfileData;
    return user_delete == otherTyped.user_delete;
    
  }
  @override
  int get hashCode => user_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_delete != null) {
      json['user_delete'] = user_delete!.toJson();
    }
    return json;
  }

  DeleteUserProfileData({
    this.user_delete,
  });
}

@immutable
class DeleteUserProfileVariables {
  final String username;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteUserProfileVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteUserProfileVariables otherTyped = other as DeleteUserProfileVariables;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  DeleteUserProfileVariables({
    required this.username,
  });
}

