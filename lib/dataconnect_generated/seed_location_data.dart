part of 'generated.dart';

class SeedLocationDataVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  SeedLocationDataVariablesBuilder(this._dataConnect, );
  Deserializer<SeedLocationDataData> dataDeserializer = (dynamic json)  => SeedLocationDataData.fromJson(jsonDecode(json));
  
  Future<OperationResult<SeedLocationDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedLocationDataData, void> ref() {
    
    return _dataConnect.mutation("seedLocationData", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class SeedLocationDataContinentInsertMany {
  final int id;
  SeedLocationDataContinentInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedLocationDataContinentInsertMany otherTyped = other as SeedLocationDataContinentInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    return json;
  }

  SeedLocationDataContinentInsertMany({
    required this.id,
  });
}

@immutable
class SeedLocationDataCountryInsertMany {
  final int id;
  SeedLocationDataCountryInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedLocationDataCountryInsertMany otherTyped = other as SeedLocationDataCountryInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    return json;
  }

  SeedLocationDataCountryInsertMany({
    required this.id,
  });
}

@immutable
class SeedLocationDataCountryContinentInsertMany {
  final int countryId;
  final int continentId;
  SeedLocationDataCountryContinentInsertMany.fromJson(dynamic json):
  
  countryId = nativeFromJson<int>(json['countryId']),
  continentId = nativeFromJson<int>(json['continentId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedLocationDataCountryContinentInsertMany otherTyped = other as SeedLocationDataCountryContinentInsertMany;
    return countryId == otherTyped.countryId && 
    continentId == otherTyped.continentId;
    
  }
  @override
  int get hashCode => Object.hashAll([countryId.hashCode, continentId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['countryId'] = nativeToJson<int>(countryId);
    json['continentId'] = nativeToJson<int>(continentId);
    return json;
  }

  SeedLocationDataCountryContinentInsertMany({
    required this.countryId,
    required this.continentId,
  });
}

@immutable
class SeedLocationDataData {
  final List<SeedLocationDataContinentInsertMany> continent_insertMany;
  final List<SeedLocationDataCountryInsertMany> country_insertMany;
  final List<SeedLocationDataCountryContinentInsertMany> countryContinent_insertMany;
  SeedLocationDataData.fromJson(dynamic json):
  
  continent_insertMany = (json['continent_insertMany'] as List<dynamic>)
        .map((e) => SeedLocationDataContinentInsertMany.fromJson(e))
        .toList(),
  country_insertMany = (json['country_insertMany'] as List<dynamic>)
        .map((e) => SeedLocationDataCountryInsertMany.fromJson(e))
        .toList(),
  countryContinent_insertMany = (json['countryContinent_insertMany'] as List<dynamic>)
        .map((e) => SeedLocationDataCountryContinentInsertMany.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedLocationDataData otherTyped = other as SeedLocationDataData;
    return continent_insertMany == otherTyped.continent_insertMany && 
    country_insertMany == otherTyped.country_insertMany && 
    countryContinent_insertMany == otherTyped.countryContinent_insertMany;
    
  }
  @override
  int get hashCode => Object.hashAll([continent_insertMany.hashCode, country_insertMany.hashCode, countryContinent_insertMany.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['continent_insertMany'] = continent_insertMany.map((e) => e.toJson()).toList();
    json['country_insertMany'] = country_insertMany.map((e) => e.toJson()).toList();
    json['countryContinent_insertMany'] = countryContinent_insertMany.map((e) => e.toJson()).toList();
    return json;
  }

  SeedLocationDataData({
    required this.continent_insertMany,
    required this.country_insertMany,
    required this.countryContinent_insertMany,
  });
}

