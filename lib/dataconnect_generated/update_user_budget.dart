part of 'generated.dart';

class UpdateUserBudgetVariablesBuilder {
  String username;
  double budget;

  final FirebaseDataConnect _dataConnect;
  UpdateUserBudgetVariablesBuilder(this._dataConnect, {required  this.username,required  this.budget,});
  Deserializer<UpdateUserBudgetData> dataDeserializer = (dynamic json)  => UpdateUserBudgetData.fromJson(jsonDecode(json));
  Serializer<UpdateUserBudgetVariables> varsSerializer = (UpdateUserBudgetVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateUserBudgetData, UpdateUserBudgetVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateUserBudgetData, UpdateUserBudgetVariables> ref() {
    UpdateUserBudgetVariables vars= UpdateUserBudgetVariables(username: username,budget: budget,);
    return _dataConnect.mutation("UpdateUserBudget", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateUserBudgetUserUpdate {
  final String username;
  UpdateUserBudgetUserUpdate.fromJson(dynamic json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserBudgetUserUpdate otherTyped = other as UpdateUserBudgetUserUpdate;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  UpdateUserBudgetUserUpdate({
    required this.username,
  });
}

@immutable
class UpdateUserBudgetData {
  final UpdateUserBudgetUserUpdate? user_update;
  UpdateUserBudgetData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateUserBudgetUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserBudgetData otherTyped = other as UpdateUserBudgetData;
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

  UpdateUserBudgetData({
    this.user_update,
  });
}

@immutable
class UpdateUserBudgetVariables {
  final String username;
  final double budget;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateUserBudgetVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']),
  budget = nativeFromJson<double>(json['budget']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserBudgetVariables otherTyped = other as UpdateUserBudgetVariables;
    return username == otherTyped.username && 
    budget == otherTyped.budget;
    
  }
  @override
  int get hashCode => Object.hashAll([username.hashCode, budget.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    json['budget'] = nativeToJson<double>(budget);
    return json;
  }

  UpdateUserBudgetVariables({
    required this.username,
    required this.budget,
  });
}

