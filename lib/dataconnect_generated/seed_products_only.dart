part of 'generated.dart';

class SeedProductsOnlyVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  SeedProductsOnlyVariablesBuilder(this._dataConnect);
  Deserializer<SeedProductsOnlyData> dataDeserializer = (dynamic json) =>
      SeedProductsOnlyData.fromJson(jsonDecode(json));

  Future<OperationResult<SeedProductsOnlyData, void>> execute() {
    return ref().execute();
  }

  MutationRef<SeedProductsOnlyData, void> ref() {
    return _dataConnect.mutation(
      "SeedProductsOnly",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class SeedProductsOnlyProductInsertMany {
  final String id;
  SeedProductsOnlyProductInsertMany.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedProductsOnlyProductInsertMany otherTyped =
        other as SeedProductsOnlyProductInsertMany;
    return id == otherTyped.id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SeedProductsOnlyProductInsertMany({required this.id});
}

@immutable
class SeedProductsOnlyData {
  final List<SeedProductsOnlyProductInsertMany> product_insertMany;
  SeedProductsOnlyData.fromJson(dynamic json)
    : product_insertMany = (json['product_insertMany'] as List<dynamic>)
          .map((e) => SeedProductsOnlyProductInsertMany.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final SeedProductsOnlyData otherTyped = other as SeedProductsOnlyData;
    return product_insertMany == otherTyped.product_insertMany;
  }

  @override
  int get hashCode => product_insertMany.hashCode;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['product_insertMany'] = product_insertMany
        .map((e) => e.toJson())
        .toList();
    return json;
  }

  SeedProductsOnlyData({required this.product_insertMany});
}
