part of 'generated.dart';

class UpsertCategoryBudgetVariablesBuilder {
  String userId;
  String categoryId;
  int budgetAmount;

  final FirebaseDataConnect _dataConnect;
  UpsertCategoryBudgetVariablesBuilder(this._dataConnect, {required  this.userId,required  this.categoryId,required  this.budgetAmount,});
  Deserializer<UpsertCategoryBudgetData> dataDeserializer = (dynamic json)  => UpsertCategoryBudgetData.fromJson(jsonDecode(json));
  Serializer<UpsertCategoryBudgetVariables> varsSerializer = (UpsertCategoryBudgetVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertCategoryBudgetData, UpsertCategoryBudgetVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertCategoryBudgetData, UpsertCategoryBudgetVariables> ref() {
    UpsertCategoryBudgetVariables vars= UpsertCategoryBudgetVariables(userId: userId,categoryId: categoryId,budgetAmount: budgetAmount,);
    return _dataConnect.mutation("UpsertCategoryBudget", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertCategoryBudgetCategoryBudgetUpsert {
  final String userUserId;
  final String categoryId;
  UpsertCategoryBudgetCategoryBudgetUpsert.fromJson(dynamic json):
  
  userUserId = nativeFromJson<String>(json['userUserId']),
  categoryId = nativeFromJson<String>(json['categoryId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertCategoryBudgetCategoryBudgetUpsert otherTyped = other as UpsertCategoryBudgetCategoryBudgetUpsert;
    return userUserId == otherTyped.userUserId && 
    categoryId == otherTyped.categoryId;
    
  }
  @override
  int get hashCode => Object.hashAll([userUserId.hashCode, categoryId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userUserId'] = nativeToJson<String>(userUserId);
    json['categoryId'] = nativeToJson<String>(categoryId);
    return json;
  }

  UpsertCategoryBudgetCategoryBudgetUpsert({
    required this.userUserId,
    required this.categoryId,
  });
}

@immutable
class UpsertCategoryBudgetData {
  final UpsertCategoryBudgetCategoryBudgetUpsert categoryBudget_upsert;
  UpsertCategoryBudgetData.fromJson(dynamic json):
  
  categoryBudget_upsert = UpsertCategoryBudgetCategoryBudgetUpsert.fromJson(json['categoryBudget_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertCategoryBudgetData otherTyped = other as UpsertCategoryBudgetData;
    return categoryBudget_upsert == otherTyped.categoryBudget_upsert;
    
  }
  @override
  int get hashCode => categoryBudget_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['categoryBudget_upsert'] = categoryBudget_upsert.toJson();
    return json;
  }

  UpsertCategoryBudgetData({
    required this.categoryBudget_upsert,
  });
}

@immutable
class UpsertCategoryBudgetVariables {
  final String userId;
  final String categoryId;
  final int budgetAmount;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertCategoryBudgetVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  categoryId = nativeFromJson<String>(json['categoryId']),
  budgetAmount = nativeFromJson<int>(json['budgetAmount']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertCategoryBudgetVariables otherTyped = other as UpsertCategoryBudgetVariables;
    return userId == otherTyped.userId && 
    categoryId == otherTyped.categoryId && 
    budgetAmount == otherTyped.budgetAmount;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, categoryId.hashCode, budgetAmount.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['categoryId'] = nativeToJson<String>(categoryId);
    json['budgetAmount'] = nativeToJson<int>(budgetAmount);
    return json;
  }

  UpsertCategoryBudgetVariables({
    required this.userId,
    required this.categoryId,
    required this.budgetAmount,
  });
}

