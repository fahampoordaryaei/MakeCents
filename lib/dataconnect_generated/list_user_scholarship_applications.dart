part of 'generated.dart';

class ListUserScholarshipApplicationsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListUserScholarshipApplicationsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListUserScholarshipApplicationsData> dataDeserializer = (dynamic json)  => ListUserScholarshipApplicationsData.fromJson(jsonDecode(json));
  Serializer<ListUserScholarshipApplicationsVariables> varsSerializer = (ListUserScholarshipApplicationsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListUserScholarshipApplicationsData, ListUserScholarshipApplicationsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListUserScholarshipApplicationsData, ListUserScholarshipApplicationsVariables> ref() {
    ListUserScholarshipApplicationsVariables vars= ListUserScholarshipApplicationsVariables(userId: userId,);
    return _dataConnect.query("ListUserScholarshipApplications", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListUserScholarshipApplicationsScholarshipApplications {
  final String id;
  final Timestamp appliedAt;
  final String? message;
  final ListUserScholarshipApplicationsScholarshipApplicationsScholarship scholarship;
  ListUserScholarshipApplicationsScholarshipApplications.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  appliedAt = Timestamp.fromJson(json['appliedAt']),
  message = json['message'] == null ? null : nativeFromJson<String>(json['message']),
  scholarship = ListUserScholarshipApplicationsScholarshipApplicationsScholarship.fromJson(json['scholarship']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipApplicationsScholarshipApplications otherTyped = other as ListUserScholarshipApplicationsScholarshipApplications;
    return id == otherTyped.id && 
    appliedAt == otherTyped.appliedAt && 
    message == otherTyped.message && 
    scholarship == otherTyped.scholarship;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, appliedAt.hashCode, message.hashCode, scholarship.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['appliedAt'] = appliedAt.toJson();
    if (message != null) {
      json['message'] = nativeToJson<String?>(message);
    }
    json['scholarship'] = scholarship.toJson();
    return json;
  }

  ListUserScholarshipApplicationsScholarshipApplications({
    required this.id,
    required this.appliedAt,
    this.message,
    required this.scholarship,
  });
}

@immutable
class ListUserScholarshipApplicationsScholarshipApplicationsScholarship {
  final String id;
  final String title;
  final String provider;
  final double amount;
  final String currency;
  final String description;
  final String color;
  ListUserScholarshipApplicationsScholarshipApplicationsScholarship.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  provider = nativeFromJson<String>(json['provider']),
  amount = nativeFromJson<double>(json['amount']),
  currency = nativeFromJson<String>(json['currency']),
  description = nativeFromJson<String>(json['description']),
  color = nativeFromJson<String>(json['color']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipApplicationsScholarshipApplicationsScholarship otherTyped = other as ListUserScholarshipApplicationsScholarshipApplicationsScholarship;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    provider == otherTyped.provider && 
    amount == otherTyped.amount && 
    currency == otherTyped.currency && 
    description == otherTyped.description && 
    color == otherTyped.color;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, provider.hashCode, amount.hashCode, currency.hashCode, description.hashCode, color.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['provider'] = nativeToJson<String>(provider);
    json['amount'] = nativeToJson<double>(amount);
    json['currency'] = nativeToJson<String>(currency);
    json['description'] = nativeToJson<String>(description);
    json['color'] = nativeToJson<String>(color);
    return json;
  }

  ListUserScholarshipApplicationsScholarshipApplicationsScholarship({
    required this.id,
    required this.title,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.description,
    required this.color,
  });
}

@immutable
class ListUserScholarshipApplicationsData {
  final List<ListUserScholarshipApplicationsScholarshipApplications> scholarshipApplications;
  ListUserScholarshipApplicationsData.fromJson(dynamic json):
  
  scholarshipApplications = (json['scholarshipApplications'] as List<dynamic>)
        .map((e) => ListUserScholarshipApplicationsScholarshipApplications.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipApplicationsData otherTyped = other as ListUserScholarshipApplicationsData;
    return scholarshipApplications == otherTyped.scholarshipApplications;
    
  }
  @override
  int get hashCode => scholarshipApplications.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarshipApplications'] = scholarshipApplications.map((e) => e.toJson()).toList();
    return json;
  }

  ListUserScholarshipApplicationsData({
    required this.scholarshipApplications,
  });
}

@immutable
class ListUserScholarshipApplicationsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListUserScholarshipApplicationsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserScholarshipApplicationsVariables otherTyped = other as ListUserScholarshipApplicationsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListUserScholarshipApplicationsVariables({
    required this.userId,
  });
}

