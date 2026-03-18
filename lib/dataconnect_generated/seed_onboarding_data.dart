part of 'generated.dart';

class SeedOnboardingDataVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  SeedOnboardingDataVariablesBuilder(this._dataConnect, );
  Deserializer<SeedOnboardingDataData> dataDeserializer = (dynamic json)  => SeedOnboardingDataData.fromJson(jsonDecode(json));
  
  Future<OperationResult<SeedOnboardingDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedOnboardingDataData, void> ref() {
    
    return _dataConnect.mutation("SeedOnboardingData", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class SeedOnboardingDataInstitutionInsertMany {
  final String id;
  SeedOnboardingDataInstitutionInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedOnboardingDataInstitutionInsertMany otherTyped = other as SeedOnboardingDataInstitutionInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedOnboardingDataInstitutionInsertMany({
    required this.id,
  });
}

@immutable
class SeedOnboardingDataCourseInsertMany {
  final String id;
  SeedOnboardingDataCourseInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedOnboardingDataCourseInsertMany otherTyped = other as SeedOnboardingDataCourseInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedOnboardingDataCourseInsertMany({
    required this.id,
  });
}

@immutable
class SeedOnboardingDataData {
  final List<SeedOnboardingDataInstitutionInsertMany> institution_insertMany;
  final List<SeedOnboardingDataCourseInsertMany> course_insertMany;
  SeedOnboardingDataData.fromJson(dynamic json):
  
  institution_insertMany = (json['institution_insertMany'] as List<dynamic>)
        .map((e) => SeedOnboardingDataInstitutionInsertMany.fromJson(e))
        .toList(),
  course_insertMany = (json['course_insertMany'] as List<dynamic>)
        .map((e) => SeedOnboardingDataCourseInsertMany.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedOnboardingDataData otherTyped = other as SeedOnboardingDataData;
    return institution_insertMany == otherTyped.institution_insertMany && 
    course_insertMany == otherTyped.course_insertMany;
    
  }
  @override
  int get hashCode => Object.hashAll([institution_insertMany.hashCode, course_insertMany.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['institution_insertMany'] = institution_insertMany.map((e) => e.toJson()).toList();
    json['course_insertMany'] = course_insertMany.map((e) => e.toJson()).toList();
    return json;
  }

  SeedOnboardingDataData({
    required this.institution_insertMany,
    required this.course_insertMany,
  });
}

