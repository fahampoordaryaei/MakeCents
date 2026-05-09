part of 'generated.dart';

class ScholarshipApplicationExistsVariablesBuilder {
  String userId;
  String scholarshipId;

  final FirebaseDataConnect _dataConnect;
  ScholarshipApplicationExistsVariablesBuilder(this._dataConnect, {required  this.userId,required  this.scholarshipId,});
  Deserializer<ScholarshipApplicationExistsData> dataDeserializer = (dynamic json)  => ScholarshipApplicationExistsData.fromJson(jsonDecode(json));
  Serializer<ScholarshipApplicationExistsVariables> varsSerializer = (ScholarshipApplicationExistsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ScholarshipApplicationExistsData, ScholarshipApplicationExistsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ScholarshipApplicationExistsData, ScholarshipApplicationExistsVariables> ref() {
    ScholarshipApplicationExistsVariables vars= ScholarshipApplicationExistsVariables(userId: userId,scholarshipId: scholarshipId,);
    return _dataConnect.query("ScholarshipApplicationExists", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ScholarshipApplicationExistsScholarshipApplications {
  final String id;
  ScholarshipApplicationExistsScholarshipApplications.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ScholarshipApplicationExistsScholarshipApplications otherTyped = other as ScholarshipApplicationExistsScholarshipApplications;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ScholarshipApplicationExistsScholarshipApplications({
    required this.id,
  });
}

@immutable
class ScholarshipApplicationExistsData {
  final List<ScholarshipApplicationExistsScholarshipApplications> scholarshipApplications;
  ScholarshipApplicationExistsData.fromJson(dynamic json):
  
  scholarshipApplications = (json['scholarshipApplications'] as List<dynamic>)
        .map((e) => ScholarshipApplicationExistsScholarshipApplications.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ScholarshipApplicationExistsData otherTyped = other as ScholarshipApplicationExistsData;
    return scholarshipApplications == otherTyped.scholarshipApplications;
    
  }
  @override
  int get hashCode => scholarshipApplications.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarshipApplications'] = scholarshipApplications.map((e) => e.toJson()).toList();
    return json;
  }

  ScholarshipApplicationExistsData({
    required this.scholarshipApplications,
  });
}

@immutable
class ScholarshipApplicationExistsVariables {
  final String userId;
  final String scholarshipId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ScholarshipApplicationExistsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  scholarshipId = nativeFromJson<String>(json['scholarshipId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ScholarshipApplicationExistsVariables otherTyped = other as ScholarshipApplicationExistsVariables;
    return userId == otherTyped.userId && 
    scholarshipId == otherTyped.scholarshipId;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, scholarshipId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['scholarshipId'] = nativeToJson<String>(scholarshipId);
    return json;
  }

  ScholarshipApplicationExistsVariables({
    required this.userId,
    required this.scholarshipId,
  });
}

