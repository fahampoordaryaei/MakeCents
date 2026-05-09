part of 'generated.dart';

class UpdateTransactionVariablesBuilder {
  String id;
  String categoryId;
  double amount;
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  DateTime date;

  final FirebaseDataConnect _dataConnect;  UpdateTransactionVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  UpdateTransactionVariablesBuilder(this._dataConnect, {required  this.id,required  this.categoryId,required  this.amount,required  this.date,});
  Deserializer<UpdateTransactionData> dataDeserializer = (dynamic json)  => UpdateTransactionData.fromJson(jsonDecode(json));
  Serializer<UpdateTransactionVariables> varsSerializer = (UpdateTransactionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateTransactionData, UpdateTransactionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateTransactionData, UpdateTransactionVariables> ref() {
    UpdateTransactionVariables vars= UpdateTransactionVariables(id: id,categoryId: categoryId,amount: amount,description: _description,date: date,);
    return _dataConnect.mutation("UpdateTransaction", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateTransactionTransactionUpdate {
  final String id;
  UpdateTransactionTransactionUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTransactionTransactionUpdate otherTyped = other as UpdateTransactionTransactionUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateTransactionTransactionUpdate({
    required this.id,
  });
}

@immutable
class UpdateTransactionData {
  final UpdateTransactionTransactionUpdate? transaction_update;
  UpdateTransactionData.fromJson(dynamic json):
  
  transaction_update = json['transaction_update'] == null ? null : UpdateTransactionTransactionUpdate.fromJson(json['transaction_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTransactionData otherTyped = other as UpdateTransactionData;
    return transaction_update == otherTyped.transaction_update;
    
  }
  @override
  int get hashCode => transaction_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (transaction_update != null) {
      json['transaction_update'] = transaction_update!.toJson();
    }
    return json;
  }

  UpdateTransactionData({
    this.transaction_update,
  });
}

@immutable
class UpdateTransactionVariables {
  final String id;
  final String categoryId;
  final double amount;
  late final Optional<String>description;
  final DateTime date;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateTransactionVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  categoryId = nativeFromJson<String>(json['categoryId']),
  amount = nativeFromJson<double>(json['amount']),
  date = nativeFromJson<DateTime>(json['date']) {
  
  
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTransactionVariables otherTyped = other as UpdateTransactionVariables;
    return id == otherTyped.id && 
    categoryId == otherTyped.categoryId && 
    amount == otherTyped.amount && 
    description == otherTyped.description && 
    date == otherTyped.date;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, categoryId.hashCode, amount.hashCode, description.hashCode, date.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['categoryId'] = nativeToJson<String>(categoryId);
    json['amount'] = nativeToJson<double>(amount);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    json['date'] = nativeToJson<DateTime>(date);
    return json;
  }

  UpdateTransactionVariables({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
  });
}

