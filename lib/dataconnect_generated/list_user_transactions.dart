part of 'generated.dart';

class ListUserTransactionsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListUserTransactionsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListUserTransactionsData> dataDeserializer = (dynamic json)  => ListUserTransactionsData.fromJson(jsonDecode(json));
  Serializer<ListUserTransactionsVariables> varsSerializer = (ListUserTransactionsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListUserTransactionsData, ListUserTransactionsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListUserTransactionsData, ListUserTransactionsVariables> ref() {
    ListUserTransactionsVariables vars= ListUserTransactionsVariables(userId: userId,);
    return _dataConnect.query("ListUserTransactions", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListUserTransactionsTransactions {
  final String id;
  final double amount;
  final String? description;
  final DateTime date;
  final String category;
  ListUserTransactionsTransactions.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  amount = nativeFromJson<double>(json['amount']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  date = nativeFromJson<DateTime>(json['date']),
  category = nativeFromJson<String>(json['category']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserTransactionsTransactions otherTyped = other as ListUserTransactionsTransactions;
    return id == otherTyped.id && 
    amount == otherTyped.amount && 
    description == otherTyped.description && 
    date == otherTyped.date && 
    category == otherTyped.category;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, amount.hashCode, description.hashCode, date.hashCode, category.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['amount'] = nativeToJson<double>(amount);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['date'] = nativeToJson<DateTime>(date);
    json['category'] = nativeToJson<String>(category);
    return json;
  }

  ListUserTransactionsTransactions({
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.category,
  });
}

@immutable
class ListUserTransactionsData {
  final List<ListUserTransactionsTransactions> transactions;
  ListUserTransactionsData.fromJson(dynamic json):
  
  transactions = (json['transactions'] as List<dynamic>)
        .map((e) => ListUserTransactionsTransactions.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserTransactionsData otherTyped = other as ListUserTransactionsData;
    return transactions == otherTyped.transactions;
    
  }
  @override
  int get hashCode => transactions.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['transactions'] = transactions.map((e) => e.toJson()).toList();
    return json;
  }

  ListUserTransactionsData({
    required this.transactions,
  });
}

@immutable
class ListUserTransactionsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListUserTransactionsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUserTransactionsVariables otherTyped = other as ListUserTransactionsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListUserTransactionsVariables({
    required this.userId,
  });
}

