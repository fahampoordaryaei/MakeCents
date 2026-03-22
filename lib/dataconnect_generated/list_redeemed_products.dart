part of 'generated.dart';

class ListRedeemedProductsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListRedeemedProductsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListRedeemedProductsData> dataDeserializer = (dynamic json)  => ListRedeemedProductsData.fromJson(jsonDecode(json));
  Serializer<ListRedeemedProductsVariables> varsSerializer = (ListRedeemedProductsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListRedeemedProductsData, ListRedeemedProductsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListRedeemedProductsData, ListRedeemedProductsVariables> ref() {
    ListRedeemedProductsVariables vars= ListRedeemedProductsVariables(userId: userId,);
    return _dataConnect.query("ListRedeemedProducts", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListRedeemedProductsRedeemedProducts {
  final String code;
  final Timestamp redeemedAt;
  final ListRedeemedProductsRedeemedProductsProduct product;
  ListRedeemedProductsRedeemedProducts.fromJson(dynamic json):
  
  code = nativeFromJson<String>(json['code']),
  redeemedAt = Timestamp.fromJson(json['redeemedAt']),
  product = ListRedeemedProductsRedeemedProductsProduct.fromJson(json['product']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRedeemedProductsRedeemedProducts otherTyped = other as ListRedeemedProductsRedeemedProducts;
    return code == otherTyped.code && 
    redeemedAt == otherTyped.redeemedAt && 
    product == otherTyped.product;
    
  }
  @override
  int get hashCode => Object.hashAll([code.hashCode, redeemedAt.hashCode, product.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['code'] = nativeToJson<String>(code);
    json['redeemedAt'] = redeemedAt.toJson();
    json['product'] = product.toJson();
    return json;
  }

  ListRedeemedProductsRedeemedProducts({
    required this.code,
    required this.redeemedAt,
    required this.product,
  });
}

@immutable
class ListRedeemedProductsRedeemedProductsProduct {
  final String id;
  final String name;
  final String description;
  final String storeName;
  final int cost;
  final bool active;
  ListRedeemedProductsRedeemedProductsProduct.fromJson(dynamic json):
  
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

    final ListRedeemedProductsRedeemedProductsProduct otherTyped = other as ListRedeemedProductsRedeemedProductsProduct;
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

  ListRedeemedProductsRedeemedProductsProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.storeName,
    required this.cost,
    required this.active,
  });
}

@immutable
class ListRedeemedProductsData {
  final List<ListRedeemedProductsRedeemedProducts> redeemedProducts;
  ListRedeemedProductsData.fromJson(dynamic json):
  
  redeemedProducts = (json['redeemedProducts'] as List<dynamic>)
        .map((e) => ListRedeemedProductsRedeemedProducts.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRedeemedProductsData otherTyped = other as ListRedeemedProductsData;
    return redeemedProducts == otherTyped.redeemedProducts;
    
  }
  @override
  int get hashCode => redeemedProducts.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['redeemedProducts'] = redeemedProducts.map((e) => e.toJson()).toList();
    return json;
  }

  ListRedeemedProductsData({
    required this.redeemedProducts,
  });
}

@immutable
class ListRedeemedProductsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListRedeemedProductsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRedeemedProductsVariables otherTyped = other as ListRedeemedProductsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListRedeemedProductsVariables({
    required this.userId,
  });
}

