part of 'generated.dart';

class ListProductsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListProductsVariablesBuilder(this._dataConnect, );
  Deserializer<ListProductsData> dataDeserializer = (dynamic json)  => ListProductsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListProductsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListProductsData, void> ref() {
    
    return _dataConnect.query("ListProducts", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListProductsProducts {
  final String id;
  final String name;
  final String description;
  final String storeName;
  final int cost;
  final bool active;
  ListProductsProducts.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  description = nativeFromJson<String>(json['description']),
  storeName = nativeFromJson<String>(json['storeName']),
  cost = nativeFromJson<int>(json['cost']),
  active = nativeFromJson<bool>(json['active']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListProductsProducts otherTyped = other as ListProductsProducts;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    description == otherTyped.description && 
    storeName == otherTyped.storeName && 
    cost == otherTyped.cost && 
    active == otherTyped.active;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, description.hashCode, storeName.hashCode, cost.hashCode, active.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['description'] = nativeToJson<String>(description);
    json['storeName'] = nativeToJson<String>(storeName);
    json['cost'] = nativeToJson<int>(cost);
    json['active'] = nativeToJson<bool>(active);
    return json;
  }

  ListProductsProducts({
    required this.id,
    required this.name,
    required this.description,
    required this.storeName,
    required this.cost,
    required this.active,
  });
}

@immutable
class ListProductsData {
  final List<ListProductsProducts> products;
  ListProductsData.fromJson(dynamic json):
  
  products = (json['products'] as List<dynamic>)
        .map((e) => ListProductsProducts.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListProductsData otherTyped = other as ListProductsData;
    return products == otherTyped.products;
    
  }
  @override
  int get hashCode => products.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['products'] = products.map((e) => e.toJson()).toList();
    return json;
  }

  ListProductsData({
    required this.products,
  });
}

