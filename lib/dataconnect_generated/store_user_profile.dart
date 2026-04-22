part of 'generated.dart';

class StoreUserProfileVariablesBuilder {
  String userId;
  String email;
  String firstName;
  String lastName;
  Optional<String> _institutionId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _courseId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _otherSchool = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _otherCourse = Optional.optional(nativeFromJson, nativeToJson);
  Optional<double> _budget = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _countryId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _currencyId = Optional.optional(nativeFromJson, nativeToJson);
  Optional<bool> _isWeekly = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  StoreUserProfileVariablesBuilder institutionId(String? t) {
   _institutionId.value = t;
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
  StoreUserProfileVariablesBuilder budget(double? t) {
   _budget.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder countryId(int? t) {
   _countryId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder currencyId(int? t) {
   _currencyId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder isWeekly(bool? t) {
   _isWeekly.value = t;
   return this;
  }

  StoreUserProfileVariablesBuilder(this._dataConnect, {required  this.userId,required  this.email,required  this.firstName,required  this.lastName,});
  Deserializer<StoreUserProfileData> dataDeserializer = (dynamic json)  => StoreUserProfileData.fromJson(jsonDecode(json));
  Serializer<StoreUserProfileVariables> varsSerializer = (StoreUserProfileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<StoreUserProfileData, StoreUserProfileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<StoreUserProfileData, StoreUserProfileVariables> ref() {
    StoreUserProfileVariables vars= StoreUserProfileVariables(userId: userId,email: email,firstName: firstName,lastName: lastName,institutionId: _institutionId,courseId: _courseId,otherSchool: _otherSchool,otherCourse: _otherCourse,budget: _budget,countryId: _countryId,currencyId: _currencyId,isWeekly: _isWeekly,);
    return _dataConnect.mutation("StoreUserProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class StoreUserProfileUserUpsert {
  final String userId;
  StoreUserProfileUserUpsert.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final StoreUserProfileUserUpsert otherTyped = other as StoreUserProfileUserUpsert;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  StoreUserProfileUserUpsert({
    required this.userId,
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
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  late final Optional<String>institutionId;
  late final Optional<String>courseId;
  late final Optional<String>otherSchool;
  late final Optional<String>otherCourse;
  late final Optional<double>budget;
  late final Optional<int>countryId;
  late final Optional<int>currencyId;
  late final Optional<bool>isWeekly;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  StoreUserProfileVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  email = nativeFromJson<String>(json['email']),
  firstName = nativeFromJson<String>(json['firstName']),
  lastName = nativeFromJson<String>(json['lastName']) {
  
  
  
  
  
  
    institutionId = Optional.optional(nativeFromJson, nativeToJson);
    institutionId.value = json['institutionId'] == null ? null : nativeFromJson<String>(json['institutionId']);
  
  
    courseId = Optional.optional(nativeFromJson, nativeToJson);
    courseId.value = json['courseId'] == null ? null : nativeFromJson<String>(json['courseId']);
  
  
    otherSchool = Optional.optional(nativeFromJson, nativeToJson);
    otherSchool.value = json['otherSchool'] == null ? null : nativeFromJson<String>(json['otherSchool']);
  
  
    otherCourse = Optional.optional(nativeFromJson, nativeToJson);
    otherCourse.value = json['otherCourse'] == null ? null : nativeFromJson<String>(json['otherCourse']);
  
  
    budget = Optional.optional(nativeFromJson, nativeToJson);
    budget.value = json['budget'] == null ? null : nativeFromJson<double>(json['budget']);
  
  
    countryId = Optional.optional(nativeFromJson, nativeToJson);
    countryId.value = json['countryId'] == null ? null : nativeFromJson<int>(json['countryId']);
  
  
    currencyId = Optional.optional(nativeFromJson, nativeToJson);
    currencyId.value = json['currencyId'] == null ? null : nativeFromJson<int>(json['currencyId']);
  
  
    isWeekly = Optional.optional(nativeFromJson, nativeToJson);
    isWeekly.value = json['isWeekly'] == null ? null : nativeFromJson<bool>(json['isWeekly']);
  
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
    return userId == otherTyped.userId && 
    email == otherTyped.email && 
    firstName == otherTyped.firstName && 
    lastName == otherTyped.lastName && 
    institutionId == otherTyped.institutionId && 
    courseId == otherTyped.courseId && 
    otherSchool == otherTyped.otherSchool && 
    otherCourse == otherTyped.otherCourse && 
    budget == otherTyped.budget && 
    countryId == otherTyped.countryId && 
    currencyId == otherTyped.currencyId && 
    isWeekly == otherTyped.isWeekly;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, email.hashCode, firstName.hashCode, lastName.hashCode, institutionId.hashCode, courseId.hashCode, otherSchool.hashCode, otherCourse.hashCode, budget.hashCode, countryId.hashCode, currencyId.hashCode, isWeekly.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['email'] = nativeToJson<String>(email);
    json['firstName'] = nativeToJson<String>(firstName);
    json['lastName'] = nativeToJson<String>(lastName);
    if(institutionId.state == OptionalState.set) {
      json['institutionId'] = institutionId.toJson();
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
    if(budget.state == OptionalState.set) {
      json['budget'] = budget.toJson();
    }
    if(countryId.state == OptionalState.set) {
      json['countryId'] = countryId.toJson();
    }
    if(currencyId.state == OptionalState.set) {
      json['currencyId'] = currencyId.toJson();
    }
    if(isWeekly.state == OptionalState.set) {
      json['isWeekly'] = isWeekly.toJson();
    }
    return json;
  }

  StoreUserProfileVariables({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.institutionId,
    required this.courseId,
    required this.otherSchool,
    required this.otherCourse,
    required this.budget,
    required this.countryId,
    required this.currencyId,
    required this.isWeekly,
  });
}

