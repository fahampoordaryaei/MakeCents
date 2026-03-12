part of 'generated.dart';

class ListExpenseCategoriesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListExpenseCategoriesVariablesBuilder(this._dataConnect, );
  Deserializer<ListExpenseCategoriesData> dataDeserializer = (dynamic json)  => ListExpenseCategoriesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListExpenseCategoriesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListExpenseCategoriesData, void> ref() {
    
    return _dataConnect.query("ListExpenseCategories", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListExpenseCategoriesExpenseCategories {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  ListExpenseCategoriesExpenseCategories.fromJson(dynamic json):
  
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

    final ListExpenseCategoriesExpenseCategories otherTyped = other as ListExpenseCategoriesExpenseCategories;
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

  ListExpenseCategoriesExpenseCategories({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });
}

@immutable
class ListExpenseCategoriesData {
  final List<ListExpenseCategoriesExpenseCategories> expenseCategories;
  ListExpenseCategoriesData.fromJson(dynamic json):
  
  expenseCategories = (json['expenseCategories'] as List<dynamic>)
        .map((e) => ListExpenseCategoriesExpenseCategories.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListExpenseCategoriesData otherTyped = other as ListExpenseCategoriesData;
    return expenseCategories == otherTyped.expenseCategories;
    
  }
  @override
  int get hashCode => expenseCategories.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['expenseCategories'] = expenseCategories.map((e) => e.toJson()).toList();
    return json;
  }

  ListExpenseCategoriesData({
    required this.expenseCategories,
  });
}

