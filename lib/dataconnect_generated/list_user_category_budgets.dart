part of 'generated.dart';

class ListUserCategoryBudgetsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListUserCategoryBudgetsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListUserCategoryBudgetsData> dataDeserializer = (dynamic json)  => ListUserCategoryBudgetsData.fromJson(jsonDecode(json));
  Serializer<ListUserCategoryBudgetsVariables> varsSerializer = (ListUserCategoryBudgetsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListUserCategoryBudgetsData, ListUserCategoryBudgetsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListUserCategoryBudgetsData, ListUserCategoryBudgetsVariables> ref() {
    ListUserCategoryBudgetsVariables vars= ListUserCategoryBudgetsVariables(userId: userId,);
    return _dataConnect.query("ListUserCategoryBudgets", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListUserCategoryBudgetsCategoryBudgets {
  final int budgetAmount;
  final ListUserCategoryBudgetsCategoryBudgetsCategory category;
  ListUserCategoryBudgetsCategoryBudgets.fromJson(dynamic json):
  
  budgetAmount = nativeFromJson<int>(json['budgetAmount']),
  category = ListUserCategoryBudgetsCategoryBudgetsCategory.fromJson(json['category']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserCategoryBudgetsCategoryBudgets otherTyped = other as ListUserCategoryBudgetsCategoryBudgets;
    return budgetAmount == otherTyped.budgetAmount && 
    category == otherTyped.category;
    
  }
  @override
  int get hashCode => Object.hashAll([budgetAmount.hashCode, category.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['budgetAmount'] = nativeToJson<int>(budgetAmount);
    json['category'] = category.toJson();
    return json;
  }

  ListUserCategoryBudgetsCategoryBudgets({
    required this.budgetAmount,
    required this.category,
  });
}

@immutable
class ListUserCategoryBudgetsCategoryBudgetsCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  ListUserCategoryBudgetsCategoryBudgetsCategory.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  iconName = nativeFromJson<String>(json['iconName']),
  colorHex = nativeFromJson<String>(json['colorHex']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserCategoryBudgetsCategoryBudgetsCategory otherTyped = other as ListUserCategoryBudgetsCategoryBudgetsCategory;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    iconName == otherTyped.iconName && 
    colorHex == otherTyped.colorHex;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, iconName.hashCode, colorHex.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['iconName'] = nativeToJson<String>(iconName);
    json['colorHex'] = nativeToJson<String>(colorHex);
    return json;
  }

  ListUserCategoryBudgetsCategoryBudgetsCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });
}

@immutable
class ListUserCategoryBudgetsData {
  final List<ListUserCategoryBudgetsCategoryBudgets> categoryBudgets;
  ListUserCategoryBudgetsData.fromJson(dynamic json):
  
  categoryBudgets = (json['categoryBudgets'] as List<dynamic>)
        .map((e) => ListUserCategoryBudgetsCategoryBudgets.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserCategoryBudgetsData otherTyped = other as ListUserCategoryBudgetsData;
    return categoryBudgets == otherTyped.categoryBudgets;
    
  }
  @override
  int get hashCode => categoryBudgets.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['categoryBudgets'] = categoryBudgets.map((e) => e.toJson()).toList();
    return json;
  }

  ListUserCategoryBudgetsData({
    required this.categoryBudgets,
  });
}

@immutable
class ListUserCategoryBudgetsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListUserCategoryBudgetsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserCategoryBudgetsVariables otherTyped = other as ListUserCategoryBudgetsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListUserCategoryBudgetsVariables({
    required this.userId,
  });
}

