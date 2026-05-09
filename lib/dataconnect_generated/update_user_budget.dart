part of 'generated.dart';

class UpdateUserBudgetVariablesBuilder {
  String userId;
  double budget;
  Optional<bool> _isWeekly = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpdateUserBudgetVariablesBuilder isWeekly(bool? t) {
   _isWeekly.value = t;
   return this;
  }

  UpdateUserBudgetVariablesBuilder(this._dataConnect, {required  this.userId,required  this.budget,});
  Deserializer<UpdateUserBudgetData> dataDeserializer = (dynamic json)  => UpdateUserBudgetData.fromJson(jsonDecode(json));
  Serializer<UpdateUserBudgetVariables> varsSerializer = (UpdateUserBudgetVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateUserBudgetData, UpdateUserBudgetVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateUserBudgetData, UpdateUserBudgetVariables> ref() {
    UpdateUserBudgetVariables vars= UpdateUserBudgetVariables(userId: userId,budget: budget,isWeekly: _isWeekly,);
    return _dataConnect.mutation("UpdateUserBudget", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateUserBudgetUserUpdate {
  final String userId;
  UpdateUserBudgetUserUpdate.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserBudgetUserUpdate otherTyped = other as UpdateUserBudgetUserUpdate;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  UpdateUserBudgetUserUpdate({
    required this.userId,
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
  final String userId;
  final double budget;
  late final Optional<bool>isWeekly;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateUserBudgetVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  budget = nativeFromJson<double>(json['budget']) {
  
  
  
  
    isWeekly = Optional.optional(nativeFromJson, nativeToJson);
    isWeekly.value = json['isWeekly'] == null ? null : nativeFromJson<bool>(json['isWeekly']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserBudgetVariables otherTyped = other as UpdateUserBudgetVariables;
    return userId == otherTyped.userId && 
    budget == otherTyped.budget && 
    isWeekly == otherTyped.isWeekly;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, budget.hashCode, isWeekly.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['budget'] = nativeToJson<double>(budget);
    if(isWeekly.state == OptionalState.set) {
      json['isWeekly'] = isWeekly.toJson();
    }
    return json;
  }

  UpdateUserBudgetVariables({
    required this.userId,
    required this.budget,
    required this.isWeekly,
  });
}

