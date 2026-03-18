part of 'generated.dart';

class ListCoursesVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListCoursesVariablesBuilder(this._dataConnect);
  Deserializer<ListCoursesData> dataDeserializer = (dynamic json) =>
      ListCoursesData.fromJson(jsonDecode(json));

  Future<QueryResult<ListCoursesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListCoursesData, void> ref() {
    return _dataConnect.query(
      "ListCourses",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class ListCoursesCourses {
  final String id;
  final String name;
  ListCoursesCourses.fromJson(dynamic json)
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

    final ListCoursesCourses otherTyped = other as ListCoursesCourses;
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

  ListCoursesCourses({required this.id, required this.name});
}

@immutable
class ListCoursesData {
  final List<ListCoursesCourses> courses;
  ListCoursesData.fromJson(dynamic json)
    : courses = (json['courses'] as List<dynamic>)
          .map((e) => ListCoursesCourses.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListCoursesData otherTyped = other as ListCoursesData;
    return courses == otherTyped.courses;
  }

  @override
  int get hashCode => courses.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['courses'] = courses.map((e) => e.toJson()).toList();
    return json;
  }

  ListCoursesData({required this.courses});
}
