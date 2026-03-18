part of 'generated.dart';

class SeedFullDataVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  SeedFullDataVariablesBuilder(this._dataConnect);
  Deserializer<SeedFullDataData> dataDeserializer = (dynamic json) =>
      SeedFullDataData.fromJson(jsonDecode(json));

  Future<OperationResult<SeedFullDataData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedFullDataData, void> ref() {
    return _dataConnect.mutation(
      "SeedFullData",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class SeedFullDataExpenseCategoryInsertMany {
  final String id;
  SeedFullDataExpenseCategoryInsertMany.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedFullDataExpenseCategoryInsertMany otherTyped =
        other as SeedFullDataExpenseCategoryInsertMany;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedFullDataExpenseCategoryInsertMany({required this.id});
}

@immutable
class SeedFullDataScholarshipInsertMany {
  final String id;
  SeedFullDataScholarshipInsertMany.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedFullDataScholarshipInsertMany otherTyped =
        other as SeedFullDataScholarshipInsertMany;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedFullDataScholarshipInsertMany({required this.id});
}

@immutable
class SeedFullDataProductInsertMany {
  final String id;
  SeedFullDataProductInsertMany.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedFullDataProductInsertMany otherTyped =
        other as SeedFullDataProductInsertMany;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedFullDataProductInsertMany({required this.id});
}

@immutable
class SeedFullDataData {
  final List<SeedFullDataExpenseCategoryInsertMany> expenseCategory_insertMany;
  final List<SeedFullDataScholarshipInsertMany> scholarship_insertMany;
  final List<SeedFullDataProductInsertMany> product_insertMany;
  SeedFullDataData.fromJson(dynamic json)
    : expenseCategory_insertMany =
          (json['expenseCategory_insertMany'] as List<dynamic>)
              .map((e) => SeedFullDataExpenseCategoryInsertMany.fromJson(e))
              .toList(),
      scholarship_insertMany = (json['scholarship_insertMany'] as List<dynamic>)
          .map((e) => SeedFullDataScholarshipInsertMany.fromJson(e))
          .toList(),
      product_insertMany = (json['product_insertMany'] as List<dynamic>)
          .map((e) => SeedFullDataProductInsertMany.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedFullDataData otherTyped = other as SeedFullDataData;
    return expenseCategory_insertMany ==
            otherTyped.expenseCategory_insertMany &&
        scholarship_insertMany == otherTyped.scholarship_insertMany &&
        product_insertMany == otherTyped.product_insertMany;
  }

  @override
  int get hashCode => Object.hashAll([
    expenseCategory_insertMany.hashCode,
    scholarship_insertMany.hashCode,
    product_insertMany.hashCode,
  ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['expenseCategory_insertMany'] = expenseCategory_insertMany
        .map((e) => e.toJson())
        .toList();
    json['scholarship_insertMany'] = scholarship_insertMany
        .map((e) => e.toJson())
        .toList();
    json['product_insertMany'] = product_insertMany
        .map((e) => e.toJson())
        .toList();
    return json;
  }

  SeedFullDataData({
    required this.expenseCategory_insertMany,
    required this.scholarship_insertMany,
    required this.product_insertMany,
  });
}
