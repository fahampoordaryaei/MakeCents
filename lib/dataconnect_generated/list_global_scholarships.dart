part of 'generated.dart';

class ListGlobalScholarshipsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListGlobalScholarshipsVariablesBuilder(this._dataConnect, );
  Deserializer<ListGlobalScholarshipsData> dataDeserializer = (dynamic json)  => ListGlobalScholarshipsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListGlobalScholarshipsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListGlobalScholarshipsData, void> ref() {
    
    return _dataConnect.query("ListGlobalScholarships", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListGlobalScholarshipsScholarships {
  final String id;
  final String title;
  final String provider;
  final String email;
  final double amount;
  final String currency;
  final List<ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse> courses_via_ScholarshipCourse;
  final String description;
  final String color;
  final ListGlobalScholarshipsScholarshipsCountry? country;
  final ListGlobalScholarshipsScholarshipsContinent? continent;
  ListGlobalScholarshipsScholarships.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  provider = nativeFromJson<String>(json['provider']),
  email = nativeFromJson<String>(json['email']),
  amount = nativeFromJson<double>(json['amount']),
  currency = nativeFromJson<String>(json['currency']),
  courses_via_ScholarshipCourse = (json['courses_via_ScholarshipCourse'] as List<dynamic>)
        .map((e) => ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse.fromJson(e))
        .toList(),
  description = nativeFromJson<String>(json['description']),
  color = nativeFromJson<String>(json['color']),
  country = json['country'] == null ? null : ListGlobalScholarshipsScholarshipsCountry.fromJson(json['country']),
  continent = json['continent'] == null ? null : ListGlobalScholarshipsScholarshipsContinent.fromJson(json['continent']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListGlobalScholarshipsScholarships otherTyped = other as ListGlobalScholarshipsScholarships;
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

  ListGlobalScholarshipsScholarships({
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
class ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse {
  final String id;
  final String name;
  ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse.fromJson(dynamic json):
  
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

    final ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse otherTyped = other as ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse;
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

  ListGlobalScholarshipsScholarshipsCoursesViaScholarshipCourse({
    required this.id,
    required this.name,
  });
}

@immutable
class ListGlobalScholarshipsScholarshipsCountry {
  final int id;
  final String countryCode;
  final String name;
  ListGlobalScholarshipsScholarshipsCountry.fromJson(dynamic json):
  
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

    final ListGlobalScholarshipsScholarshipsCountry otherTyped = other as ListGlobalScholarshipsScholarshipsCountry;
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

  ListGlobalScholarshipsScholarshipsCountry({
    required this.id,
    required this.countryCode,
    required this.name,
  });
}

@immutable
class ListGlobalScholarshipsScholarshipsContinent {
  final int id;
  final String code;
  final String name;
  ListGlobalScholarshipsScholarshipsContinent.fromJson(dynamic json):
  
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

    final ListGlobalScholarshipsScholarshipsContinent otherTyped = other as ListGlobalScholarshipsScholarshipsContinent;
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

  ListGlobalScholarshipsScholarshipsContinent({
    required this.id,
    required this.code,
    required this.name,
  });
}

@immutable
class ListGlobalScholarshipsData {
  final List<ListGlobalScholarshipsScholarships> scholarships;
  ListGlobalScholarshipsData.fromJson(dynamic json):
  
  scholarships = (json['scholarships'] as List<dynamic>)
        .map((e) => ListGlobalScholarshipsScholarships.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListGlobalScholarshipsData otherTyped = other as ListGlobalScholarshipsData;
    return scholarships == otherTyped.scholarships;
    
  }
  @override
  int get hashCode => scholarships.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarships'] = scholarships.map((e) => e.toJson()).toList();
    return json;
  }

  ListGlobalScholarshipsData({
    required this.scholarships,
  });
}

