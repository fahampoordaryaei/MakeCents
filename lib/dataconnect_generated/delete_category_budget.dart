part of 'generated.dart';

class DeleteCategoryBudgetVariablesBuilder {
  String userId;
  String categoryId;

  final FirebaseDataConnect _dataConnect;
  DeleteCategoryBudgetVariablesBuilder(this._dataConnect, {required  this.userId,required  this.categoryId,});
  Deserializer<DeleteCategoryBudgetData> dataDeserializer = (dynamic json)  => DeleteCategoryBudgetData.fromJson(jsonDecode(json));
  Serializer<DeleteCategoryBudgetVariables> varsSerializer = (DeleteCategoryBudgetVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteCategoryBudgetData, DeleteCategoryBudgetVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteCategoryBudgetData, DeleteCategoryBudgetVariables> ref() {
    DeleteCategoryBudgetVariables vars= DeleteCategoryBudgetVariables(userId: userId,categoryId: categoryId,);
    return _dataConnect.mutation("DeleteCategoryBudget", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteCategoryBudgetCategoryBudgetDelete {
  final String userUserId;
  final String categoryId;
  DeleteCategoryBudgetCategoryBudgetDelete.fromJson(dynamic json):
  
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

    final DeleteCategoryBudgetCategoryBudgetDelete otherTyped = other as DeleteCategoryBudgetCategoryBudgetDelete;
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

  DeleteCategoryBudgetCategoryBudgetDelete({
    required this.userUserId,
    required this.categoryId,
  });
}

@immutable
class DeleteCategoryBudgetData {
  final DeleteCategoryBudgetCategoryBudgetDelete? categoryBudget_delete;
  DeleteCategoryBudgetData.fromJson(dynamic json):
  
  categoryBudget_delete = json['categoryBudget_delete'] == null ? null : DeleteCategoryBudgetCategoryBudgetDelete.fromJson(json['categoryBudget_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCategoryBudgetData otherTyped = other as DeleteCategoryBudgetData;
    return categoryBudget_delete == otherTyped.categoryBudget_delete;
    
  }
  @override
  int get hashCode => categoryBudget_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (categoryBudget_delete != null) {
      json['categoryBudget_delete'] = categoryBudget_delete!.toJson();
    }
    return json;
  }

  DeleteCategoryBudgetData({
    this.categoryBudget_delete,
  });
}

@immutable
class DeleteCategoryBudgetVariables {
  final String userId;
  final String categoryId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteCategoryBudgetVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  categoryId = nativeFromJson<String>(json['categoryId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteCategoryBudgetVariables otherTyped = other as DeleteCategoryBudgetVariables;
    return userId == otherTyped.userId && 
    categoryId == otherTyped.categoryId;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, categoryId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['categoryId'] = nativeToJson<String>(categoryId);
    return json;
  }

  DeleteCategoryBudgetVariables({
    required this.userId,
    required this.categoryId,
  });
}

