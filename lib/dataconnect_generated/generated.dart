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

part 'update_user_budget.dart';

part 'get_user_profile.dart';

part 'list_scholarships.dart';

part 'list_expense_categories.dart';

part 'init_points_balance.dart';

part 'update_points_balance.dart';

part 'seed_full_data.dart';

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
  
  
  AddTransactionVariablesBuilder addTransaction ({required String userId, required String categoryId, required double amount, required DateTime date, }) {
    return AddTransactionVariablesBuilder(dataConnect, userId: userId,categoryId: categoryId,amount: amount,date: date,);
  }
  
  
  StoreUserProfileVariablesBuilder storeUserProfile ({required String username, required String email, required String firstName, required String lastName, }) {
    return StoreUserProfileVariablesBuilder(dataConnect, username: username,email: email,firstName: firstName,lastName: lastName,);
  }
  
  
  DeleteTransactionVariablesBuilder deleteTransaction ({required String id, }) {
    return DeleteTransactionVariablesBuilder(dataConnect, id: id,);
  }
  
  
  UpdateUserBudgetVariablesBuilder updateUserBudget ({required String username, required double budget, }) {
    return UpdateUserBudgetVariablesBuilder(dataConnect, username: username,budget: budget,);
  }
  
  
  GetUserProfileVariablesBuilder getUserProfile ({required String username, }) {
    return GetUserProfileVariablesBuilder(dataConnect, username: username,);
  }
  
  
  ListScholarshipsVariablesBuilder listScholarships () {
    return ListScholarshipsVariablesBuilder(dataConnect, );
  }
  
  
  ListExpenseCategoriesVariablesBuilder listExpenseCategories () {
    return ListExpenseCategoriesVariablesBuilder(dataConnect, );
  }
  
  
  InitPointsBalanceVariablesBuilder initPointsBalance ({required String userId, required int totalPoints, }) {
    return InitPointsBalanceVariablesBuilder(dataConnect, userId: userId,totalPoints: totalPoints,);
  }
  
  
  UpdatePointsBalanceVariablesBuilder updatePointsBalance ({required String id, required int totalPoints, }) {
    return UpdatePointsBalanceVariablesBuilder(dataConnect, id: id,totalPoints: totalPoints,);
  }
  
  
  SeedFullDataVariablesBuilder seedFullData () {
    return SeedFullDataVariablesBuilder(dataConnect, );
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
