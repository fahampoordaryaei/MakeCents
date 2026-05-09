part of 'generated.dart';

class GetCountryIdByCodeVariablesBuilder {
  String code;

  final FirebaseDataConnect _dataConnect;
  GetCountryIdByCodeVariablesBuilder(this._dataConnect, {required  this.code,});
  Deserializer<GetCountryIdByCodeData> dataDeserializer = (dynamic json)  => GetCountryIdByCodeData.fromJson(jsonDecode(json));
  Serializer<GetCountryIdByCodeVariables> varsSerializer = (GetCountryIdByCodeVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetCountryIdByCodeData, GetCountryIdByCodeVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetCountryIdByCodeData, GetCountryIdByCodeVariables> ref() {
    GetCountryIdByCodeVariables vars= GetCountryIdByCodeVariables(code: code,);
    return _dataConnect.query("GetCountryIdByCode", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetCountryIdByCodeCountries {
  final int id;
  final String countryCode;
  final String name;
  GetCountryIdByCodeCountries.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']),
  countryCode = nativeFromJson<String>(json['countryCode']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCountryIdByCodeCountries otherTyped = other as GetCountryIdByCodeCountries;
    return id == otherTyped.id && 
    countryCode == otherTyped.countryCode && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, countryCode.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    json['countryCode'] = nativeToJson<String>(countryCode);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  GetCountryIdByCodeCountries({
    required this.id,
    required this.countryCode,
    required this.name,
  });
}

@immutable
class GetCountryIdByCodeData {
  final List<GetCountryIdByCodeCountries> countries;
  GetCountryIdByCodeData.fromJson(dynamic json):
  
  countries = (json['countries'] as List<dynamic>)
        .map((e) => GetCountryIdByCodeCountries.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCountryIdByCodeData otherTyped = other as GetCountryIdByCodeData;
    return countries == otherTyped.countries;
    
  }
  @override
  int get hashCode => countries.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['countries'] = countries.map((e) => e.toJson()).toList();
    return json;
  }

  GetCountryIdByCodeData({
    required this.countries,
  });
}

@immutable
class GetCountryIdByCodeVariables {
  final String code;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetCountryIdByCodeVariables.fromJson(Map<String, dynamic> json):
  
  code = nativeFromJson<String>(json['code']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCountryIdByCodeVariables otherTyped = other as GetCountryIdByCodeVariables;
    return code == otherTyped.code;
    
  }
  @override
  int get hashCode => code.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['code'] = nativeToJson<String>(code);
    return json;
  }

  GetCountryIdByCodeVariables({
    required this.code,
  });
}

