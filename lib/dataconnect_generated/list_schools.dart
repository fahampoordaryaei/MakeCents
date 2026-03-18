part of 'generated.dart';

class ListSchoolsVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListSchoolsVariablesBuilder(this._dataConnect);
  Deserializer<ListSchoolsData> dataDeserializer = (dynamic json) =>
      ListSchoolsData.fromJson(jsonDecode(json));

  Future<QueryResult<ListSchoolsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListSchoolsData, void> ref() {
    return _dataConnect.query(
      "ListSchools",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class ListSchoolsSchools {
  final String id;
  final String name;
  ListSchoolsSchools.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']),
      name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListSchoolsSchools otherTyped = other as ListSchoolsSchools;
    return id == otherTyped.id && name == otherTyped.name;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListSchoolsSchools({required this.id, required this.name});
}

@immutable
class ListSchoolsData {
  final List<ListSchoolsSchools> schools;
  ListSchoolsData.fromJson(dynamic json)
    : schools = (json['schools'] as List<dynamic>)
          .map((e) => ListSchoolsSchools.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListSchoolsData otherTyped = other as ListSchoolsData;
    return schools == otherTyped.schools;
  }

  @override
  int get hashCode => schools.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['schools'] = schools.map((e) => e.toJson()).toList();
    return json;
  }

  ListSchoolsData({required this.schools});
}
