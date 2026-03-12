part of 'generated.dart';

class StoreUserProfileVariablesBuilder {
  String username;
  String email;
  String firstName;
  String lastName;
  Optional<String> _schoolId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _courseId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _otherSchool = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _otherCourse = Optional.optional(nativeFromJson, nativeToJson);
  Optional<double> _monthlyBudget = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  StoreUserProfileVariablesBuilder schoolId(String? t) {
   _schoolId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder courseId(String? t) {
   _courseId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder otherSchool(String? t) {
   _otherSchool.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder otherCourse(String? t) {
   _otherCourse.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder monthlyBudget(double? t) {
   _monthlyBudget.value = t;
   return this;
  }

  StoreUserProfileVariablesBuilder(this._dataConnect, {required  this.username,required  this.email,required  this.firstName,required  this.lastName,});
  Deserializer<StoreUserProfileData> dataDeserializer = (dynamic json)  => StoreUserProfileData.fromJson(jsonDecode(json));
  Serializer<StoreUserProfileVariables> varsSerializer = (StoreUserProfileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<StoreUserProfileData, StoreUserProfileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<StoreUserProfileData, StoreUserProfileVariables> ref() {
    StoreUserProfileVariables vars= StoreUserProfileVariables(username: username,email: email,firstName: firstName,lastName: lastName,schoolId: _schoolId,courseId: _courseId,otherSchool: _otherSchool,otherCourse: _otherCourse,monthlyBudget: _monthlyBudget,);
    return _dataConnect.mutation("StoreUserProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class StoreUserProfileUserUpsert {
  final String username;
  StoreUserProfileUserUpsert.fromJson(dynamic json):
  
  username = nativeFromJson<String>(json['username']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StoreUserProfileUserUpsert otherTyped = other as StoreUserProfileUserUpsert;
    return username == otherTyped.username;
    
  }
  @override
  int get hashCode => username.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    return json;
  }

  StoreUserProfileUserUpsert({
    required this.username,
  });
}

@immutable
class StoreUserProfileData {
  final StoreUserProfileUserUpsert user_upsert;
  StoreUserProfileData.fromJson(dynamic json):
  
  user_upsert = StoreUserProfileUserUpsert.fromJson(json['user_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StoreUserProfileData otherTyped = other as StoreUserProfileData;
    return user_upsert == otherTyped.user_upsert;
    
  }
  @override
  int get hashCode => user_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_upsert'] = user_upsert.toJson();
    return json;
  }

  StoreUserProfileData({
    required this.user_upsert,
  });
}

@immutable
class StoreUserProfileVariables {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  late final Optional<String>schoolId;
  late final Optional<String>courseId;
  late final Optional<String>otherSchool;
  late final Optional<String>otherCourse;
  late final Optional<double>monthlyBudget;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  StoreUserProfileVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']),
  email = nativeFromJson<String>(json['email']),
  firstName = nativeFromJson<String>(json['firstName']),
  lastName = nativeFromJson<String>(json['lastName']) {
  
  
  
  
  
  
    schoolId = Optional.optional(nativeFromJson, nativeToJson);
    schoolId.value = json['schoolId'] == null ? null : nativeFromJson<String>(json['schoolId']);
  
  
    courseId = Optional.optional(nativeFromJson, nativeToJson);
    courseId.value = json['courseId'] == null ? null : nativeFromJson<String>(json['courseId']);
  
  
    otherSchool = Optional.optional(nativeFromJson, nativeToJson);
    otherSchool.value = json['otherSchool'] == null ? null : nativeFromJson<String>(json['otherSchool']);
  
  
    otherCourse = Optional.optional(nativeFromJson, nativeToJson);
    otherCourse.value = json['otherCourse'] == null ? null : nativeFromJson<String>(json['otherCourse']);
  
  
    monthlyBudget = Optional.optional(nativeFromJson, nativeToJson);
    monthlyBudget.value = json['monthlyBudget'] == null ? null : nativeFromJson<double>(json['monthlyBudget']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StoreUserProfileVariables otherTyped = other as StoreUserProfileVariables;
    return username == otherTyped.username && 
    email == otherTyped.email && 
    firstName == otherTyped.firstName && 
    lastName == otherTyped.lastName && 
    schoolId == otherTyped.schoolId && 
    courseId == otherTyped.courseId && 
    otherSchool == otherTyped.otherSchool && 
    otherCourse == otherTyped.otherCourse && 
    monthlyBudget == otherTyped.monthlyBudget;
    
  }
  @override
  int get hashCode => Object.hashAll([username.hashCode, email.hashCode, firstName.hashCode, lastName.hashCode, schoolId.hashCode, courseId.hashCode, otherSchool.hashCode, otherCourse.hashCode, monthlyBudget.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    json['email'] = nativeToJson<String>(email);
    json['firstName'] = nativeToJson<String>(firstName);
    json['lastName'] = nativeToJson<String>(lastName);
    if(schoolId.state == OptionalState.set) {
      json['schoolId'] = schoolId.toJson();
    }
    if(courseId.state == OptionalState.set) {
      json['courseId'] = courseId.toJson();
    }
    if(otherSchool.state == OptionalState.set) {
      json['otherSchool'] = otherSchool.toJson();
    }
    if(otherCourse.state == OptionalState.set) {
      json['otherCourse'] = otherCourse.toJson();
    }
    if(monthlyBudget.state == OptionalState.set) {
      json['monthlyBudget'] = monthlyBudget.toJson();
    }
    return json;
  }

  StoreUserProfileVariables({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.schoolId,
    required this.courseId,
    required this.otherSchool,
    required this.otherCourse,
    required this.monthlyBudget,
  });
}

