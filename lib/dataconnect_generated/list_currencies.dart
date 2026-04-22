part of 'generated.dart';

class ListCurrenciesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListCurrenciesVariablesBuilder(this._dataConnect, );
  Deserializer<ListCurrenciesData> dataDeserializer = (dynamic json)  => ListCurrenciesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListCurrenciesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListCurrenciesData, void> ref() {
    
    return _dataConnect.query("ListCurrencies", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListCurrenciesCurrencies {
  final int id;
  final String code;
  final String sign;
  ListCurrenciesCurrencies.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']),
  code = nativeFromJson<String>(json['code']),
  sign = nativeFromJson<String>(json['sign']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListCurrenciesCurrencies otherTyped = other as ListCurrenciesCurrencies;
    return id == otherTyped.id && 
    code == otherTyped.code && 
    sign == otherTyped.sign;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, code.hashCode, sign.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    json['code'] = nativeToJson<String>(code);
    json['sign'] = nativeToJson<String>(sign);
    return json;
  }

  ListCurrenciesCurrencies({
    required this.id,
    required this.code,
    required this.sign,
  });
}

@immutable
class ListCurrenciesData {
  final List<ListCurrenciesCurrencies> currencies;
  ListCurrenciesData.fromJson(dynamic json):
  
  currencies = (json['currencies'] as List<dynamic>)
        .map((e) => ListCurrenciesCurrencies.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListCurrenciesData otherTyped = other as ListCurrenciesData;
    return currencies == otherTyped.currencies;
    
  }
  @override
  int get hashCode => currencies.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['currencies'] = currencies.map((e) => e.toJson()).toList();
    return json;
  }

  ListCurrenciesData({
    required this.currencies,
  });
}

