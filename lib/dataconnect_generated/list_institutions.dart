part of 'generated.dart';

class ListInstitutionsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListInstitutionsVariablesBuilder(this._dataConnect, );
  Deserializer<ListInstitutionsData> dataDeserializer = (dynamic json)  => ListInstitutionsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListInstitutionsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListInstitutionsData, void> ref() {
    
    return _dataConnect.query("ListInstitutions", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListInstitutionsInstitutions {
  final String id;
  final String name;
  ListInstitutionsInstitutions.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListInstitutionsInstitutions otherTyped = other as ListInstitutionsInstitutions;
    return id == otherTyped.id && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListInstitutionsInstitutions({
    required this.id,
    required this.name,
  });
}

@immutable
class ListInstitutionsData {
  final List<ListInstitutionsInstitutions> institutions;
  ListInstitutionsData.fromJson(dynamic json):
  
  institutions = (json['institutions'] as List<dynamic>)
        .map((e) => ListInstitutionsInstitutions.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListInstitutionsData otherTyped = other as ListInstitutionsData;
    return institutions == otherTyped.institutions;
    
  }
  @override
  int get hashCode => institutions.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['institutions'] = institutions.map((e) => e.toJson()).toList();
    return json;
  }

  ListInstitutionsData({
    required this.institutions,
  });
}

