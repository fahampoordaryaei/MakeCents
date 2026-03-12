library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'list_user_transactions.dart';

part 'get_user_points.dart';

part 'add_transaction.dart';

part 'seed_make_cents_database.dart';







class ExampleConnector {
  
  
  ListUserTransactionsVariablesBuilder listUserTransactions ({required String userId, }) {
    return ListUserTransactionsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  GetUserPointsVariablesBuilder getUserPoints ({required String userId, }) {
    return GetUserPointsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  AddTransactionVariablesBuilder addTransaction ({required String userId, required String category, required double amount, required DateTime date, }) {
    return AddTransactionVariablesBuilder(dataConnect, userId: userId,category: category,amount: amount,date: date,);
  }
  
  
  SeedMakeCentsDatabaseVariablesBuilder seedMakeCentsDatabase () {
    return SeedMakeCentsDatabaseVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'europe-west1',
    'example',
    'makecents',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
