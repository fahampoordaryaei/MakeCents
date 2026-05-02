part of 'generated.dart';

class ListScholarshipsForUserVariablesBuilder {
  int countryId;
  int continentId;

  final FirebaseDataConnect _dataConnect;
  ListScholarshipsForUserVariablesBuilder(this._dataConnect, {required  this.countryId,required  this.continentId,});
  Deserializer<ListScholarshipsForUserData> dataDeserializer = (dynamic json)  => ListScholarshipsForUserData.fromJson(jsonDecode(json));
  Serializer<ListScholarshipsForUserVariables> varsSerializer = (ListScholarshipsForUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListScholarshipsForUserData, ListScholarshipsForUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListScholarshipsForUserData, ListScholarshipsForUserVariables> ref() {
    ListScholarshipsForUserVariables vars= ListScholarshipsForUserVariables(countryId: countryId,continentId: continentId,);
    return _dataConnect.query("ListScholarshipsForUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListScholarshipsForUserScholarships {
  final String id;
  final String title;
  final String provider;
  final String email;
  final double amount;
  final String currency;
  final List<ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse> courses_via_ScholarshipCourse;
  final String description;
  final String color;
  final ListScholarshipsForUserScholarshipsCountry? country;
  final ListScholarshipsForUserScholarshipsContinent? continent;
  ListScholarshipsForUserScholarships.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  provider = nativeFromJson<String>(json['provider']),
  email = nativeFromJson<String>(json['email']),
  amount = nativeFromJson<double>(json['amount']),
  currency = nativeFromJson<String>(json['currency']),
  courses_via_ScholarshipCourse = (json['courses_via_ScholarshipCourse'] as List<dynamic>)
        .map((e) => ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse.fromJson(e))
        .toList(),
  description = nativeFromJson<String>(json['description']),
  color = nativeFromJson<String>(json['color']),
  country = json['country'] == null ? null : ListScholarshipsForUserScholarshipsCountry.fromJson(json['country']),
  continent = json['continent'] == null ? null : ListScholarshipsForUserScholarshipsContinent.fromJson(json['continent']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsForUserScholarships otherTyped = other as ListScholarshipsForUserScholarships;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    provider == otherTyped.provider && 
    email == otherTyped.email && 
    amount == otherTyped.amount && 
    currency == otherTyped.currency && 
    courses_via_ScholarshipCourse == otherTyped.courses_via_ScholarshipCourse && 
    description == otherTyped.description && 
    color == otherTyped.color && 
    country == otherTyped.country && 
    continent == otherTyped.continent;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, provider.hashCode, email.hashCode, amount.hashCode, currency.hashCode, courses_via_ScholarshipCourse.hashCode, description.hashCode, color.hashCode, country.hashCode, continent.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['provider'] = nativeToJson<String>(provider);
    json['email'] = nativeToJson<String>(email);
    json['amount'] = nativeToJson<double>(amount);
    json['currency'] = nativeToJson<String>(currency);
    json['courses_via_ScholarshipCourse'] = courses_via_ScholarshipCourse.map((e) => e.toJson()).toList();
    json['description'] = nativeToJson<String>(description);
    json['color'] = nativeToJson<String>(color);
    if (country != null) {
      json['country'] = country!.toJson();
    }
    if (continent != null) {
      json['continent'] = continent!.toJson();
    }
    return json;
  }

  ListScholarshipsForUserScholarships({
    required this.id,
    required this.title,
    required this.provider,
    required this.email,
    required this.amount,
    required this.currency,
    required this.courses_via_ScholarshipCourse,
    required this.description,
    required this.color,
    this.country,
    this.continent,
  });
}

@immutable
class ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse {
  final String id;
  final String name;
  ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse otherTyped = other as ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse;
    return id == otherTyped.id && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListScholarshipsForUserScholarshipsCoursesViaScholarshipCourse({
    required this.id,
    required this.name,
  });
}

@immutable
class ListScholarshipsForUserScholarshipsCountry {
  final int id;
  final String countryCode;
  final String name;
  ListScholarshipsForUserScholarshipsCountry.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']),
  countryCode = nativeFromJson<String>(json['countryCode']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsForUserScholarshipsCountry otherTyped = other as ListScholarshipsForUserScholarshipsCountry;
    return id == otherTyped.id && 
    countryCode == otherTyped.countryCode && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, countryCode.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    json['countryCode'] = nativeToJson<String>(countryCode);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListScholarshipsForUserScholarshipsCountry({
    required this.id,
    required this.countryCode,
    required this.name,
  });
}

@immutable
class ListScholarshipsForUserScholarshipsContinent {
  final int id;
  final String code;
  final String name;
  ListScholarshipsForUserScholarshipsContinent.fromJson(dynamic json):
  
  id = nativeFromJson<int>(json['id']),
  code = nativeFromJson<String>(json['code']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsForUserScholarshipsContinent otherTyped = other as ListScholarshipsForUserScholarshipsContinent;
    return id == otherTyped.id && 
    code == otherTyped.code && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, code.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<int>(id);
    json['code'] = nativeToJson<String>(code);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListScholarshipsForUserScholarshipsContinent({
    required this.id,
    required this.code,
    required this.name,
  });
}

@immutable
class ListScholarshipsForUserData {
  final List<ListScholarshipsForUserScholarships> scholarships;
  ListScholarshipsForUserData.fromJson(dynamic json):
  
  scholarships = (json['scholarships'] as List<dynamic>)
        .map((e) => ListScholarshipsForUserScholarships.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsForUserData otherTyped = other as ListScholarshipsForUserData;
    return scholarships == otherTyped.scholarships;
    
  }
  @override
  int get hashCode => scholarships.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarships'] = scholarships.map((e) => e.toJson()).toList();
    return json;
  }

  ListScholarshipsForUserData({
    required this.scholarships,
  });
}

@immutable
class ListScholarshipsForUserVariables {
  final int countryId;
  final int continentId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListScholarshipsForUserVariables.fromJson(Map<String, dynamic> json):
  
  countryId = nativeFromJson<int>(json['countryId']),
  continentId = nativeFromJson<int>(json['continentId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsForUserVariables otherTyped = other as ListScholarshipsForUserVariables;
    return countryId == otherTyped.countryId && 
    continentId == otherTyped.continentId;
    
  }
  @override
  int get hashCode => Object.hashAll([countryId.hashCode, continentId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['countryId'] = nativeToJson<int>(countryId);
    json['continentId'] = nativeToJson<int>(continentId);
    return json;
  }

  ListScholarshipsForUserVariables({
    required this.countryId,
    required this.continentId,
  });
}

