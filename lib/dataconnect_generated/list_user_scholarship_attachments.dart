part of 'generated.dart';

class ListUserScholarshipAttachmentsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListUserScholarshipAttachmentsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListUserScholarshipAttachmentsData> dataDeserializer = (dynamic json)  => ListUserScholarshipAttachmentsData.fromJson(jsonDecode(json));
  Serializer<ListUserScholarshipAttachmentsVariables> varsSerializer = (ListUserScholarshipAttachmentsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListUserScholarshipAttachmentsData, ListUserScholarshipAttachmentsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListUserScholarshipAttachmentsData, ListUserScholarshipAttachmentsVariables> ref() {
    ListUserScholarshipAttachmentsVariables vars= ListUserScholarshipAttachmentsVariables(userId: userId,);
    return _dataConnect.query("ListUserScholarshipAttachments", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListUserScholarshipAttachmentsScholarshipAttachments {
  final String id;
  final String filename;
  final String path;
  final ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication scholarshipApplication;
  ListUserScholarshipAttachmentsScholarshipAttachments.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  filename = nativeFromJson<String>(json['filename']),
  path = nativeFromJson<String>(json['path']),
  scholarshipApplication = ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication.fromJson(json['scholarshipApplication']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipAttachmentsScholarshipAttachments otherTyped = other as ListUserScholarshipAttachmentsScholarshipAttachments;
    return id == otherTyped.id && 
    filename == otherTyped.filename && 
    path == otherTyped.path && 
    scholarshipApplication == otherTyped.scholarshipApplication;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, filename.hashCode, path.hashCode, scholarshipApplication.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['filename'] = nativeToJson<String>(filename);
    json['path'] = nativeToJson<String>(path);
    json['scholarshipApplication'] = scholarshipApplication.toJson();
    return json;
  }

  ListUserScholarshipAttachmentsScholarshipAttachments({
    required this.id,
    required this.filename,
    required this.path,
    required this.scholarshipApplication,
  });
}

@immutable
class ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication {
  final String id;
  ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication otherTyped = other as ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  ListUserScholarshipAttachmentsScholarshipAttachmentsScholarshipApplication({
    required this.id,
  });
}

@immutable
class ListUserScholarshipAttachmentsData {
  final List<ListUserScholarshipAttachmentsScholarshipAttachments> scholarshipAttachments;
  ListUserScholarshipAttachmentsData.fromJson(dynamic json):
  
  scholarshipAttachments = (json['scholarshipAttachments'] as List<dynamic>)
        .map((e) => ListUserScholarshipAttachmentsScholarshipAttachments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipAttachmentsData otherTyped = other as ListUserScholarshipAttachmentsData;
    return scholarshipAttachments == otherTyped.scholarshipAttachments;
    
  }
  @override
  int get hashCode => scholarshipAttachments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarshipAttachments'] = scholarshipAttachments.map((e) => e.toJson()).toList();
    return json;
  }

  ListUserScholarshipAttachmentsData({
    required this.scholarshipAttachments,
  });
}

@immutable
class ListUserScholarshipAttachmentsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListUserScholarshipAttachmentsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipAttachmentsVariables otherTyped = other as ListUserScholarshipAttachmentsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListUserScholarshipAttachmentsVariables({
    required this.userId,
  });
}

