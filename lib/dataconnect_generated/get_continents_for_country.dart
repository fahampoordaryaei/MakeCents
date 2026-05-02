part of 'generated.dart';

class GetContinentsForCountryVariablesBuilder {
  int countryId;

  final FirebaseDataConnect _dataConnect;
  GetContinentsForCountryVariablesBuilder(this._dataConnect, {required  this.countryId,});
  Deserializer<GetContinentsForCountryData> dataDeserializer = (dynamic json)  => GetContinentsForCountryData.fromJson(jsonDecode(json));
  Serializer<GetContinentsForCountryVariables> varsSerializer = (GetContinentsForCountryVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetContinentsForCountryData, GetContinentsForCountryVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetContinentsForCountryData, GetContinentsForCountryVariables> ref() {
    GetContinentsForCountryVariables vars= GetContinentsForCountryVariables(countryId: countryId,);
    return _dataConnect.query("GetContinentsForCountry", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetContinentsForCountryCountryContinents {
  final GetContinentsForCountryCountryContinentsContinent continent;
  GetContinentsForCountryCountryContinents.fromJson(dynamic json):
  
  continent = GetContinentsForCountryCountryContinentsContinent.fromJson(json['continent']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetContinentsForCountryCountryContinents otherTyped = other as GetContinentsForCountryCountryContinents;
    return continent == otherTyped.continent;
    
  }
  @override
  int get hashCode => continent.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['continent'] = continent.toJson();
    return json;
  }

  GetContinentsForCountryCountryContinents({
    required this.continent,
  });
}

@immutable
class GetContinentsForCountryCountryContinentsContinent {
  final int id;
  final String code;
  final String name;
  GetContinentsForCountryCountryContinentsContinent.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']),
  code = nativeFromJson<String>(json['code']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetContinentsForCountryCountryContinentsContinent otherTyped = other as GetContinentsForCountryCountryContinentsContinent;
    return id == otherTyped.id && 
    code == otherTyped.code && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, code.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    json['code'] = nativeToJson<String>(code);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  GetContinentsForCountryCountryContinentsContinent({
    required this.id,
    required this.code,
    required this.name,
  });
}

@immutable
class GetContinentsForCountryData {
  final List<GetContinentsForCountryCountryContinents> countryContinents;
  GetContinentsForCountryData.fromJson(dynamic json):
  
  countryContinents = (json['countryContinents'] as List<dynamic>)
        .map((e) => GetContinentsForCountryCountryContinents.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetContinentsForCountryData otherTyped = other as GetContinentsForCountryData;
    return countryContinents == otherTyped.countryContinents;
    
  }
  @override
  int get hashCode => countryContinents.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['countryContinents'] = countryContinents.map((e) => e.toJson()).toList();
    return json;
  }

  GetContinentsForCountryData({
    required this.countryContinents,
  });
}

@immutable
class GetContinentsForCountryVariables {
  final int countryId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetContinentsForCountryVariables.fromJson(Map<String, dynamic> json):
  
  countryId = nativeFromJson<int>(json['countryId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetContinentsForCountryVariables otherTyped = other as GetContinentsForCountryVariables;
    return countryId == otherTyped.countryId;
    
  }
  @override
  int get hashCode => countryId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['countryId'] = nativeToJson<int>(countryId);
    return json;
  }

  GetContinentsForCountryVariables({
    required this.countryId,
  });
}

