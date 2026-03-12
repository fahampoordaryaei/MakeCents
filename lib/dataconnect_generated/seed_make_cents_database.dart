part of 'generated.dart';

class SeedMakeCentsDatabaseVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  SeedMakeCentsDatabaseVariablesBuilder(this._dataConnect, );
  Deserializer<SeedMakeCentsDatabaseData> dataDeserializer = (dynamic json)  => SeedMakeCentsDatabaseData.fromJson(jsonDecode(json));
  
  Future<OperationResult<SeedMakeCentsDatabaseData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedMakeCentsDatabaseData, void> ref() {
    
    return _dataConnect.mutation("SeedMakeCentsDatabase", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class SeedMakeCentsDatabaseInstitutionInsert {
  final String id;
  SeedMakeCentsDatabaseInstitutionInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedMakeCentsDatabaseInstitutionInsert otherTyped = other as SeedMakeCentsDatabaseInstitutionInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedMakeCentsDatabaseInstitutionInsert({
    required this.id,
  });
}

@immutable
class SeedMakeCentsDatabaseData {
  final SeedMakeCentsDatabaseInstitutionInsert institution_insert;
  SeedMakeCentsDatabaseData.fromJson(dynamic json):
  
  institution_insert = SeedMakeCentsDatabaseInstitutionInsert.fromJson(json['institution_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedMakeCentsDatabaseData otherTyped = other as SeedMakeCentsDatabaseData;
    return institution_insert == otherTyped.institution_insert;
    
  }
  @override
  int get hashCode => institution_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['institution_insert'] = institution_insert.toJson();
    return json;
  }

  SeedMakeCentsDatabaseData({
    required this.institution_insert,
  });
}

