part of 'generated.dart';

class AddTransactionVariablesBuilder {
  String userId;
  String bankAccountId;
  String categoryId;
  double amount;
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  DateTime date;

  final FirebaseDataConnect _dataConnect;  AddTransactionVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  AddTransactionVariablesBuilder(this._dataConnect, {required  this.userId,required  this.bankAccountId,required  this.categoryId,required  this.amount,required  this.date,});
  Deserializer<AddTransactionData> dataDeserializer = (dynamic json)  => AddTransactionData.fromJson(jsonDecode(json));
  Serializer<AddTransactionVariables> varsSerializer = (AddTransactionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddTransactionData, AddTransactionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddTransactionData, AddTransactionVariables> ref() {
    AddTransactionVariables vars= AddTransactionVariables(userId: userId,bankAccountId: bankAccountId,categoryId: categoryId,amount: amount,description: _description,date: date,);
    return _dataConnect.mutation("AddTransaction", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddTransactionTransactionInsert {
  final String id;
  AddTransactionTransactionInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddTransactionTransactionInsert otherTyped = other as AddTransactionTransactionInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddTransactionTransactionInsert({
    required this.id,
  });
}

@immutable
class AddTransactionData {
  final AddTransactionTransactionInsert transaction_insert;
  AddTransactionData.fromJson(dynamic json):
  
  transaction_insert = AddTransactionTransactionInsert.fromJson(json['transaction_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddTransactionData otherTyped = other as AddTransactionData;
    return transaction_insert == otherTyped.transaction_insert;
    
  }
  @override
  int get hashCode => transaction_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['transaction_insert'] = transaction_insert.toJson();
    return json;
  }

  AddTransactionData({
    required this.transaction_insert,
  });
}

@immutable
class AddTransactionVariables {
  final String userId;
  final String bankAccountId;
  final String categoryId;
  final double amount;
  late final Optional<String>description;
  final DateTime date;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddTransactionVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  bankAccountId = nativeFromJson<String>(json['bankAccountId']),
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

    final AddTransactionVariables otherTyped = other as AddTransactionVariables;
    return userId == otherTyped.userId && 
    bankAccountId == otherTyped.bankAccountId && 
    categoryId == otherTyped.categoryId && 
    amount == otherTyped.amount && 
    description == otherTyped.description && 
    date == otherTyped.date;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, bankAccountId.hashCode, categoryId.hashCode, amount.hashCode, description.hashCode, date.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['bankAccountId'] = nativeToJson<String>(bankAccountId);
    json['categoryId'] = nativeToJson<String>(categoryId);
    json['amount'] = nativeToJson<double>(amount);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    json['date'] = nativeToJson<DateTime>(date);
    return json;
  }

  AddTransactionVariables({
    required this.userId,
    required this.bankAccountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
  });
}

