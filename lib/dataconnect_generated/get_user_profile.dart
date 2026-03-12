part of 'generated.dart';

class GetUserProfileVariablesBuilder {
  String username;

  final FirebaseDataConnect _dataConnect;
  GetUserProfileVariablesBuilder(this._dataConnect, {required  this.username,});
  Deserializer<GetUserProfileData> dataDeserializer = (dynamic json)  => GetUserProfileData.fromJson(jsonDecode(json));
  Serializer<GetUserProfileVariables> varsSerializer = (GetUserProfileVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUserProfileData, GetUserProfileVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUserProfileData, GetUserProfileVariables> ref() {
    GetUserProfileVariables vars= GetUserProfileVariables(username: username,);
    return _dataConnect.query("GetUserProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetUserProfileUsers {
  final String firstName;
  final String lastName;
  final double? monthlyBudget;
  final String? otherSchool;
  final String? otherCourse;
  final GetUserProfileUsersSchool? school;
  final GetUserProfileUsersCourse? course;
  GetUserProfileUsers.fromJson(dynamic json):
  
  firstName = nativeFromJson<String>(json['firstName']),
  lastName = nativeFromJson<String>(json['lastName']),
  monthlyBudget = json['monthlyBudget'] == null ? null : nativeFromJson<double>(json['monthlyBudget']),
  otherSchool = json['otherSchool'] == null ? null : nativeFromJson<String>(json['otherSchool']),
  otherCourse = json['otherCourse'] == null ? null : nativeFromJson<String>(json['otherCourse']),
  school = json['school'] == null ? null : GetUserProfileUsersSchool.fromJson(json['school']),
  course = json['course'] == null ? null : GetUserProfileUsersCourse.fromJson(json['course']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserProfileUsers otherTyped = other as GetUserProfileUsers;
    return firstName == otherTyped.firstName && 
    lastName == otherTyped.lastName && 
    monthlyBudget == otherTyped.monthlyBudget && 
    otherSchool == otherTyped.otherSchool && 
    otherCourse == otherTyped.otherCourse && 
    school == otherTyped.school && 
    course == otherTyped.course;
    
  }
  @override
  int get hashCode => Object.hashAll([firstName.hashCode, lastName.hashCode, monthlyBudget.hashCode, otherSchool.hashCode, otherCourse.hashCode, school.hashCode, course.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['firstName'] = nativeToJson<String>(firstName);
    json['lastName'] = nativeToJson<String>(lastName);
    if (monthlyBudget != null) {
      json['monthlyBudget'] = nativeToJson<double?>(monthlyBudget);
    }
    if (otherSchool != null) {
      json['otherSchool'] = nativeToJson<String?>(otherSchool);
    }
    if (otherCourse != null) {
      json['otherCourse'] = nativeToJson<String?>(otherCourse);
    }
    if (school != null) {
      json['school'] = school!.toJson();
    }
    if (course != null) {
      json['course'] = course!.toJson();
    }
    return json;
  }

  GetUserProfileUsers({
    required this.firstName,
    required this.lastName,
    this.monthlyBudget,
    this.otherSchool,
    this.otherCourse,
    this.school,
    this.course,
  });
}

@immutable
class GetUserProfileUsersSchool {
  final String name;
  GetUserProfileUsersSchool.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserProfileUsersSchool otherTyped = other as GetUserProfileUsersSchool;
    return name == otherTyped.name;
    
  }
  @override
  int get hashCode => name.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  GetUserProfileUsersSchool({
    required this.name,
  });
}

@immutable
class GetUserProfileUsersCourse {
  final String name;
  GetUserProfileUsersCourse.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserProfileUsersCourse otherTyped = other as GetUserProfileUsersCourse;
    return name == otherTyped.name;
    
  }
  @override
  int get hashCode => name.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  GetUserProfileUsersCourse({
    required this.name,
  });
}

@immutable
class GetUserProfileData {
  final List<GetUserProfileUsers> users;
  GetUserProfileData.fromJson(dynamic json):
  
  users = (json['users'] as List<dynamic>)
        .map((e) => GetUserProfileUsers.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserProfileData otherTyped = other as GetUserProfileData;
    return users == otherTyped.users;
    
  }
  @override
  int get hashCode => users.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['users'] = users.map((e) => e.toJson()).toList();
    return json;
  }

  GetUserProfileData({
    required this.users,
  });
}

@immutable
class GetUserProfileVariables {
  final String username;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetUserProfileVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserProfileVariables otherTyped = other as GetUserProfileVariables;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  GetUserProfileVariables({
    required this.username,
  });
}

