part of 'generated.dart';

class CreateScholarshipApplicationVariablesBuilder {
  String id;
  String userId;
  String scholarshipId;
  Optional<String> _message = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateScholarshipApplicationVariablesBuilder message(String? t) {
   _message.value = t;
   return this;
  }

  CreateScholarshipApplicationVariablesBuilder(this._dataConnect, {required  this.id,required  this.userId,required  this.scholarshipId,});
  Deserializer<CreateScholarshipApplicationData> dataDeserializer = (dynamic json)  => CreateScholarshipApplicationData.fromJson(jsonDecode(json));
  Serializer<CreateScholarshipApplicationVariables> varsSerializer = (CreateScholarshipApplicationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateScholarshipApplicationData, CreateScholarshipApplicationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateScholarshipApplicationData, CreateScholarshipApplicationVariables> ref() {
    CreateScholarshipApplicationVariables vars= CreateScholarshipApplicationVariables(id: id,userId: userId,scholarshipId: scholarshipId,message: _message,);
    return _dataConnect.mutation("CreateScholarshipApplication", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateScholarshipApplicationScholarshipApplicationInsert {
  final String id;
  CreateScholarshipApplicationScholarshipApplicationInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateScholarshipApplicationScholarshipApplicationInsert otherTyped = other as CreateScholarshipApplicationScholarshipApplicationInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateScholarshipApplicationScholarshipApplicationInsert({
    required this.id,
  });
}

@immutable
class CreateScholarshipApplicationData {
  final CreateScholarshipApplicationScholarshipApplicationInsert scholarshipApplication_insert;
  CreateScholarshipApplicationData.fromJson(dynamic json):
  
  scholarshipApplication_insert = CreateScholarshipApplicationScholarshipApplicationInsert.fromJson(json['scholarshipApplication_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateScholarshipApplicationData otherTyped = other as CreateScholarshipApplicationData;
    return scholarshipApplication_insert == otherTyped.scholarshipApplication_insert;
    
  }
  @override
  int get hashCode => scholarshipApplication_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarshipApplication_insert'] = scholarshipApplication_insert.toJson();
    return json;
  }

  CreateScholarshipApplicationData({
    required this.scholarshipApplication_insert,
  });
}

@immutable
class CreateScholarshipApplicationVariables {
  final String id;
  final String userId;
  final String scholarshipId;
  late final Optional<String>message;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateScholarshipApplicationVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  userId = nativeFromJson<String>(json['userId']),
  scholarshipId = nativeFromJson<String>(json['scholarshipId']) {
  
  
  
  
  
    message = Optional.optional(nativeFromJson, nativeToJson);
    message.value = json['message'] == null ? null : nativeFromJson<String>(json['message']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateScholarshipApplicationVariables otherTyped = other as CreateScholarshipApplicationVariables;
    return id == otherTyped.id && 
    userId == otherTyped.userId && 
    scholarshipId == otherTyped.scholarshipId && 
    message == otherTyped.message;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, userId.hashCode, scholarshipId.hashCode, message.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['userId'] = nativeToJson<String>(userId);
    json['scholarshipId'] = nativeToJson<String>(scholarshipId);
    if(message.state == OptionalState.set) {
      json['message'] = message.toJson();
    }
    return json;
  }

  CreateScholarshipApplicationVariables({
    required this.id,
    required this.userId,
    required this.scholarshipId,
    required this.message,
  });
}

