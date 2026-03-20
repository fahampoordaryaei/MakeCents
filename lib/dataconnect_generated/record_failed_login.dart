part of 'generated.dart';

class RecordFailedLoginVariablesBuilder {
  String username;
  int failedAttempts;
  Optional<Timestamp> _lockedUntil = Optional.optional((json) => json['lockedUntil'] = Timestamp.fromJson(json['lockedUntil']), defaultSerializer);

  final FirebaseDataConnect _dataConnect;  RecordFailedLoginVariablesBuilder lockedUntil(Timestamp? t) {
   _lockedUntil.value = t;
   return this;
  }

  RecordFailedLoginVariablesBuilder(this._dataConnect, {required  this.username,required  this.failedAttempts,});
  Deserializer<RecordFailedLoginData> dataDeserializer = (dynamic json)  => RecordFailedLoginData.fromJson(jsonDecode(json));
  Serializer<RecordFailedLoginVariables> varsSerializer = (RecordFailedLoginVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<RecordFailedLoginData, RecordFailedLoginVariables>> execute() {
    return ref().execute();
  }

  MutationRef<RecordFailedLoginData, RecordFailedLoginVariables> ref() {
    RecordFailedLoginVariables vars= RecordFailedLoginVariables(username: username,failedAttempts: failedAttempts,lockedUntil: _lockedUntil,);
    return _dataConnect.mutation("RecordFailedLogin", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class RecordFailedLoginUserUpdate {
  final String username;
  RecordFailedLoginUserUpdate.fromJson(dynamic json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordFailedLoginUserUpdate otherTyped = other as RecordFailedLoginUserUpdate;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  RecordFailedLoginUserUpdate({
    required this.username,
  });
}

@immutable
class RecordFailedLoginData {
  final RecordFailedLoginUserUpdate? user_update;
  RecordFailedLoginData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : RecordFailedLoginUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordFailedLoginData otherTyped = other as RecordFailedLoginData;
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

  RecordFailedLoginData({
    this.user_update,
  });
}

@immutable
class RecordFailedLoginVariables {
  final String username;
  final int failedAttempts;
  late final Optional<Timestamp>lockedUntil;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  RecordFailedLoginVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']),
  failedAttempts = nativeFromJson<int>(json['failedAttempts']) {
  
  
  
  
    lockedUntil = Optional.optional((json) => json['lockedUntil'] = Timestamp.fromJson(json['lockedUntil']), defaultSerializer);
    lockedUntil.value = json['lockedUntil'] == null ? null : Timestamp.fromJson(json['lockedUntil']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final RecordFailedLoginVariables otherTyped = other as RecordFailedLoginVariables;
    return username == otherTyped.username && 
    failedAttempts == otherTyped.failedAttempts && 
    lockedUntil == otherTyped.lockedUntil;
    
  }
  @override
  int get hashCode => Object.hashAll([username.hashCode, failedAttempts.hashCode, lockedUntil.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    json['failedAttempts'] = nativeToJson<int>(failedAttempts);
    if(lockedUntil.state == OptionalState.set) {
      json['lockedUntil'] = lockedUntil.toJson();
    }
    return json;
  }

  RecordFailedLoginVariables({
    required this.username,
    required this.failedAttempts,
    required this.lockedUntil,
  });
}

