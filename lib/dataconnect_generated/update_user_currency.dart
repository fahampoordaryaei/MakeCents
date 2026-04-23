part of 'generated.dart';

class UpdateUserCurrencyVariablesBuilder {
  String userId;
  int currencyId;

  final FirebaseDataConnect _dataConnect;
  UpdateUserCurrencyVariablesBuilder(this._dataConnect, {required  this.userId,required  this.currencyId,});
  Deserializer<UpdateUserCurrencyData> dataDeserializer = (dynamic json)  => UpdateUserCurrencyData.fromJson(jsonDecode(json));
  Serializer<UpdateUserCurrencyVariables> varsSerializer = (UpdateUserCurrencyVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateUserCurrencyData, UpdateUserCurrencyVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateUserCurrencyData, UpdateUserCurrencyVariables> ref() {
    UpdateUserCurrencyVariables vars= UpdateUserCurrencyVariables(userId: userId,currencyId: currencyId,);
    return _dataConnect.mutation("UpdateUserCurrency", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateUserCurrencyUserUpdate {
  final String userId;
  UpdateUserCurrencyUserUpdate.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserCurrencyUserUpdate otherTyped = other as UpdateUserCurrencyUserUpdate;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  UpdateUserCurrencyUserUpdate({
    required this.userId,
  });
}

@immutable
class UpdateUserCurrencyData {
  final UpdateUserCurrencyUserUpdate? user_update;
  UpdateUserCurrencyData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateUserCurrencyUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserCurrencyData otherTyped = other as UpdateUserCurrencyData;
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

  UpdateUserCurrencyData({
    this.user_update,
  });
}

@immutable
class UpdateUserCurrencyVariables {
  final String userId;
  final int currencyId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateUserCurrencyVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  currencyId = nativeFromJson<int>(json['currencyId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserCurrencyVariables otherTyped = other as UpdateUserCurrencyVariables;
    return userId == otherTyped.userId && 
    currencyId == otherTyped.currencyId;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, currencyId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['currencyId'] = nativeToJson<int>(currencyId);
    return json;
  }

  UpdateUserCurrencyVariables({
    required this.userId,
    required this.currencyId,
  });
}

