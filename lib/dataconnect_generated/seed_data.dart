part of 'generated.dart';

class SeedDataVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  SeedDataVariablesBuilder(this._dataConnect, );
  Deserializer<SeedDataData> dataDeserializer = (dynamic json)  => SeedDataData.fromJson(jsonDecode(json));
  
  Future<OperationResult<SeedDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedDataData, void> ref() {
    
    return _dataConnect.mutation("seedData", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class SeedDataInstitutionInsertMany {
  final String id;
  SeedDataInstitutionInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataInstitutionInsertMany otherTyped = other as SeedDataInstitutionInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedDataInstitutionInsertMany({
    required this.id,
  });
}

@immutable
class SeedDataCourseInsertMany {
  final String id;
  SeedDataCourseInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataCourseInsertMany otherTyped = other as SeedDataCourseInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedDataCourseInsertMany({
    required this.id,
  });
}

@immutable
class SeedDataExpenseCategoryInsertMany {
  final String id;
  SeedDataExpenseCategoryInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataExpenseCategoryInsertMany otherTyped = other as SeedDataExpenseCategoryInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedDataExpenseCategoryInsertMany({
    required this.id,
  });
}

@immutable
class SeedDataScholarshipInsertMany {
  final String id;
  SeedDataScholarshipInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataScholarshipInsertMany otherTyped = other as SeedDataScholarshipInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedDataScholarshipInsertMany({
    required this.id,
  });
}

@immutable
class SeedDataProductInsertMany {
  final String id;
  SeedDataProductInsertMany.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataProductInsertMany otherTyped = other as SeedDataProductInsertMany;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedDataProductInsertMany({
    required this.id,
  });
}

@immutable
class SeedDataData {
  final List<SeedDataInstitutionInsertMany> institution_insertMany;
  final List<SeedDataCourseInsertMany> course_insertMany;
  final List<SeedDataExpenseCategoryInsertMany> expenseCategory_insertMany;
  final List<SeedDataScholarshipInsertMany> scholarship_insertMany;
  final List<SeedDataProductInsertMany> product_insertMany;
  SeedDataData.fromJson(dynamic json):
  
  institution_insertMany = (json['institution_insertMany'] as List<dynamic>)
        .map((e) => SeedDataInstitutionInsertMany.fromJson(e))
        .toList(),
  course_insertMany = (json['course_insertMany'] as List<dynamic>)
        .map((e) => SeedDataCourseInsertMany.fromJson(e))
        .toList(),
  expenseCategory_insertMany = (json['expenseCategory_insertMany'] as List<dynamic>)
        .map((e) => SeedDataExpenseCategoryInsertMany.fromJson(e))
        .toList(),
  scholarship_insertMany = (json['scholarship_insertMany'] as List<dynamic>)
        .map((e) => SeedDataScholarshipInsertMany.fromJson(e))
        .toList(),
  product_insertMany = (json['product_insertMany'] as List<dynamic>)
        .map((e) => SeedDataProductInsertMany.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SeedDataData otherTyped = other as SeedDataData;
    return institution_insertMany == otherTyped.institution_insertMany && 
    course_insertMany == otherTyped.course_insertMany && 
    expenseCategory_insertMany == otherTyped.expenseCategory_insertMany && 
    scholarship_insertMany == otherTyped.scholarship_insertMany && 
    product_insertMany == otherTyped.product_insertMany;
    
  }
  @override
  int get hashCode => Object.hashAll([institution_insertMany.hashCode, course_insertMany.hashCode, expenseCategory_insertMany.hashCode, scholarship_insertMany.hashCode, product_insertMany.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['institution_insertMany'] = institution_insertMany.map((e) => e.toJson()).toList();
    json['course_insertMany'] = course_insertMany.map((e) => e.toJson()).toList();
    json['expenseCategory_insertMany'] = expenseCategory_insertMany.map((e) => e.toJson()).toList();
    json['scholarship_insertMany'] = scholarship_insertMany.map((e) => e.toJson()).toList();
    json['product_insertMany'] = product_insertMany.map((e) => e.toJson()).toList();
    return json;
  }

  SeedDataData({
    required this.institution_insertMany,
    required this.course_insertMany,
    required this.expenseCategory_insertMany,
    required this.scholarship_insertMany,
    required this.product_insertMany,
  });
}

