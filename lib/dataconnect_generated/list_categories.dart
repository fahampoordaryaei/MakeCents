part of 'generated.dart';

class ListCategoriesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListCategoriesVariablesBuilder(this._dataConnect, );
  Deserializer<ListCategoriesData> dataDeserializer = (dynamic json)  => ListCategoriesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListCategoriesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListCategoriesData, void> ref() {
    
    return _dataConnect.query("ListCategories", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListCategoriesCategories {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  ListCategoriesCategories.fromJson(dynamic json):
  
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

    final ListCategoriesCategories otherTyped = other as ListCategoriesCategories;
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

  ListCategoriesCategories({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });
}

@immutable
class ListCategoriesData {
  final List<ListCategoriesCategories> categories;
  ListCategoriesData.fromJson(dynamic json):
  
  categories = (json['categories'] as List<dynamic>)
        .map((e) => ListCategoriesCategories.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListCategoriesData otherTyped = other as ListCategoriesData;
    return categories == otherTyped.categories;
    
  }
  @override
  int get hashCode => categories.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['categories'] = categories.map((e) => e.toJson()).toList();
    return json;
  }

  ListCategoriesData({
    required this.categories,
  });
}

