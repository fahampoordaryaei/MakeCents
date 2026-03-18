part of 'generated.dart';

class SeedOnboardingDataVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  SeedOnboardingDataVariablesBuilder(this._dataConnect);
  Deserializer<SeedOnboardingDataData> dataDeserializer = (dynamic json) =>
      SeedOnboardingDataData.fromJson(jsonDecode(json));

  Future<OperationResult<SeedOnboardingDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedOnboardingDataData, void> ref() {
    return _dataConnect.mutation(
      "SeedOnboardingData",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class SeedOnboardingDataSchoolInsertMany {
  final String id;
  SeedOnboardingDataSchoolInsertMany.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedOnboardingDataSchoolInsertMany otherTyped =
        other as SeedOnboardingDataSchoolInsertMany;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedOnboardingDataSchoolInsertMany({required this.id});
}

@immutable
class SeedOnboardingDataCourseInsertMany {
  final String id;
  SeedOnboardingDataCourseInsertMany.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedOnboardingDataCourseInsertMany otherTyped =
        other as SeedOnboardingDataCourseInsertMany;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedOnboardingDataCourseInsertMany({required this.id});
}

@immutable
class SeedOnboardingDataData {
  final List<SeedOnboardingDataSchoolInsertMany> school_insertMany;
  final List<SeedOnboardingDataCourseInsertMany> course_insertMany;
  SeedOnboardingDataData.fromJson(dynamic json)
    : school_insertMany = (json['school_insertMany'] as List<dynamic>)
          .map((e) => SeedOnboardingDataSchoolInsertMany.fromJson(e))
          .toList(),
      course_insertMany = (json['course_insertMany'] as List<dynamic>)
          .map((e) => SeedOnboardingDataCourseInsertMany.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedOnboardingDataData otherTyped = other as SeedOnboardingDataData;
    return school_insertMany == otherTyped.school_insertMany &&
        course_insertMany == otherTyped.course_insertMany;
  }

  @override
  int get hashCode =>
      Object.hashAll([school_insertMany.hashCode, course_insertMany.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['school_insertMany'] = school_insertMany
        .map((e) => e.toJson())
        .toList();
    json['course_insertMany'] = course_insertMany
        .map((e) => e.toJson())
        .toList();
    return json;
  }

  SeedOnboardingDataData({
    required this.school_insertMany,
    required this.course_insertMany,
  });
}
