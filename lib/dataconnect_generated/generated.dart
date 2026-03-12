library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'list_schools.dart';

part 'list_courses.dart';

part 'list_user_transactions.dart';

part 'get_user_points.dart';

part 'add_transaction.dart';

part 'store_user_profile.dart';

part 'delete_transaction.dart';

part 'get_user_profile.dart';

part 'seed_onboarding_data.dart';







class ExampleConnector {
  
  
  ListSchoolsVariablesBuilder listSchools () {
    return ListSchoolsVariablesBuilder(dataConnect, );
  }
  
  
  ListCoursesVariablesBuilder listCourses () {
    return ListCoursesVariablesBuilder(dataConnect, );
  }
  
  
  ListUserTransactionsVariablesBuilder listUserTransactions ({required String userId, }) {
    return ListUserTransactionsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  GetUserPointsVariablesBuilder getUserPoints ({required String userId, }) {
    return GetUserPointsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  AddTransactionVariablesBuilder addTransaction ({required String userId, required String category, required double amount, required DateTime date, }) {
    return AddTransactionVariablesBuilder(dataConnect, userId: userId,category: category,amount: amount,date: date,);
  }
  
  
  StoreUserProfileVariablesBuilder storeUserProfile ({required String username, required String email, required String firstName, required String lastName, }) {
    return StoreUserProfileVariablesBuilder(dataConnect, username: username,email: email,firstName: firstName,lastName: lastName,);
  }
  
  
  DeleteTransactionVariablesBuilder deleteTransaction ({required String id, }) {
    return DeleteTransactionVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetUserProfileVariablesBuilder getUserProfile ({required String username, }) {
    return GetUserProfileVariablesBuilder(dataConnect, username: username,);
  }
  
  
  SeedOnboardingDataVariablesBuilder seedOnboardingData () {
    return SeedOnboardingDataVariablesBuilder(dataConnect, );
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
