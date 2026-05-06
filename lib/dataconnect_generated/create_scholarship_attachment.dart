part of 'generated.dart';

class CreateScholarshipAttachmentVariablesBuilder {
  String id;
  String scholarshipApplicationId;
  String filename;
  String path;

  final FirebaseDataConnect _dataConnect;
  CreateScholarshipAttachmentVariablesBuilder(this._dataConnect, {required  this.id,required  this.scholarshipApplicationId,required  this.filename,required  this.path,});
  Deserializer<CreateScholarshipAttachmentData> dataDeserializer = (dynamic json)  => CreateScholarshipAttachmentData.fromJson(jsonDecode(json));
  Serializer<CreateScholarshipAttachmentVariables> varsSerializer = (CreateScholarshipAttachmentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateScholarshipAttachmentData, CreateScholarshipAttachmentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateScholarshipAttachmentData, CreateScholarshipAttachmentVariables> ref() {
    CreateScholarshipAttachmentVariables vars= CreateScholarshipAttachmentVariables(id: id,scholarshipApplicationId: scholarshipApplicationId,filename: filename,path: path,);
    return _dataConnect.mutation("CreateScholarshipAttachment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateScholarshipAttachmentScholarshipAttachmentInsert {
  final String id;
  CreateScholarshipAttachmentScholarshipAttachmentInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateScholarshipAttachmentScholarshipAttachmentInsert otherTyped = other as CreateScholarshipAttachmentScholarshipAttachmentInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateScholarshipAttachmentScholarshipAttachmentInsert({
    required this.id,
  });
}

@immutable
class CreateScholarshipAttachmentData {
  final CreateScholarshipAttachmentScholarshipAttachmentInsert scholarshipAttachment_insert;
  CreateScholarshipAttachmentData.fromJson(dynamic json):
  
  scholarshipAttachment_insert = CreateScholarshipAttachmentScholarshipAttachmentInsert.fromJson(json['scholarshipAttachment_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateScholarshipAttachmentData otherTyped = other as CreateScholarshipAttachmentData;
    return scholarshipAttachment_insert == otherTyped.scholarshipAttachment_insert;
    
  }
  @override
  int get hashCode => scholarshipAttachment_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarshipAttachment_insert'] = scholarshipAttachment_insert.toJson();
    return json;
  }

  CreateScholarshipAttachmentData({
    required this.scholarshipAttachment_insert,
  });
}

@immutable
class CreateScholarshipAttachmentVariables {
  final String id;
  final String scholarshipApplicationId;
  final String filename;
  final String path;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateScholarshipAttachmentVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  scholarshipApplicationId = nativeFromJson<String>(json['scholarshipApplicationId']),
  filename = nativeFromJson<String>(json['filename']),
  path = nativeFromJson<String>(json['path']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateScholarshipAttachmentVariables otherTyped = other as CreateScholarshipAttachmentVariables;
    return id == otherTyped.id && 
    scholarshipApplicationId == otherTyped.scholarshipApplicationId && 
    filename == otherTyped.filename && 
    path == otherTyped.path;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, scholarshipApplicationId.hashCode, filename.hashCode, path.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['scholarshipApplicationId'] = nativeToJson<String>(scholarshipApplicationId);
    json['filename'] = nativeToJson<String>(filename);
    json['path'] = nativeToJson<String>(path);
    return json;
  }

  CreateScholarshipAttachmentVariables({
    required this.id,
    required this.scholarshipApplicationId,
    required this.filename,
    required this.path,
  });
}

