library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'seed_data.dart';

part 'seed_location_data.dart';

part 'list_institutions.dart';

part 'list_courses.dart';

part 'list_user_transactions.dart';

part 'get_user_points.dart';

part 'list_products.dart';

part 'list_redeemed_products.dart';

part 'add_transaction.dart';

part 'store_user_profile.dart';

part 'list_currencies.dart';

part 'get_country_id_by_code.dart';

part 'delete_transaction.dart';

part 'update_transaction.dart';

part 'delete_user_profile.dart';

part 'update_user_budget.dart';

part 'get_user_profile.dart';

part 'update_user_currency.dart';

part 'list_scholarships.dart';

part 'list_expense_categories.dart';

part 'init_points_balance.dart';

part 'update_points_balance.dart';

part 'get_login_status.dart';

part 'record_failed_login.dart';

part 'reset_login_attempts.dart';

part 'list_user_category_budgets.dart';

part 'upsert_category_budget.dart';

part 'delete_category_budget.dart';







class ExampleConnector {
  
  
  SeedDataVariablesBuilder seedData () {
    return SeedDataVariablesBuilder(dataConnect, );
  }
  
  
  SeedLocationDataVariablesBuilder seedLocationData () {
    return SeedLocationDataVariablesBuilder(dataConnect, );
  }
  
  
  ListInstitutionsVariablesBuilder listInstitutions () {
    return ListInstitutionsVariablesBuilder(dataConnect, );
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
  
  
  ListProductsVariablesBuilder listProducts () {
    return ListProductsVariablesBuilder(dataConnect, );
  }
  
  
  ListRedeemedProductsVariablesBuilder listRedeemedProducts ({required String userId, }) {
    return ListRedeemedProductsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  AddTransactionVariablesBuilder addTransaction ({required String userId, required String categoryId, required double amount, required DateTime date, }) {
    return AddTransactionVariablesBuilder(dataConnect, userId: userId,categoryId: categoryId,amount: amount,date: date,);
  }
  
  
  StoreUserProfileVariablesBuilder storeUserProfile ({required String userId, required String email, required String firstName, required String lastName, }) {
    return StoreUserProfileVariablesBuilder(dataConnect, userId: userId,email: email,firstName: firstName,lastName: lastName,);
  }
  
  
  ListCurrenciesVariablesBuilder listCurrencies () {
    return ListCurrenciesVariablesBuilder(dataConnect, );
  }
  
  
  GetCountryIdByCodeVariablesBuilder getCountryIdByCode ({required String code, }) {
    return GetCountryIdByCodeVariablesBuilder(dataConnect, code: code,);
  }
  
  
  DeleteTransactionVariablesBuilder deleteTransaction ({required String id, }) {
    return DeleteTransactionVariablesBuilder(dataConnect, id: id,);
  }
  
  
  UpdateTransactionVariablesBuilder updateTransaction ({required String id, required String categoryId, required double amount, required DateTime date, }) {
    return UpdateTransactionVariablesBuilder(dataConnect, id: id,categoryId: categoryId,amount: amount,date: date,);
  }
  
  
  DeleteUserProfileVariablesBuilder deleteUserProfile ({required String userId, }) {
    return DeleteUserProfileVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  UpdateUserBudgetVariablesBuilder updateUserBudget ({required String userId, required double budget, }) {
    return UpdateUserBudgetVariablesBuilder(dataConnect, userId: userId,budget: budget,);
  }
  
  
  GetUserProfileVariablesBuilder getUserProfile ({required String userId, }) {
    return GetUserProfileVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  UpdateUserCurrencyVariablesBuilder updateUserCurrency ({required String userId, required int currencyId, }) {
    return UpdateUserCurrencyVariablesBuilder(dataConnect, userId: userId,currencyId: currencyId,);
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
  
  
  GetLoginStatusVariablesBuilder getLoginStatus ({required String email, }) {
    return GetLoginStatusVariablesBuilder(dataConnect, email: email,);
  }
  
  
  RecordFailedLoginVariablesBuilder recordFailedLogin ({required String userId, required int failedAttempts, }) {
    return RecordFailedLoginVariablesBuilder(dataConnect, userId: userId,failedAttempts: failedAttempts,);
  }
  
  
  ResetLoginAttemptsVariablesBuilder resetLoginAttempts ({required String userId, }) {
    return ResetLoginAttemptsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  ListUserCategoryBudgetsVariablesBuilder listUserCategoryBudgets ({required String userId, }) {
    return ListUserCategoryBudgetsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  UpsertCategoryBudgetVariablesBuilder upsertCategoryBudget ({required String userId, required String categoryId, required int budgetAmount, }) {
    return UpsertCategoryBudgetVariablesBuilder(dataConnect, userId: userId,categoryId: categoryId,budgetAmount: budgetAmount,);
  }
  
  
  DeleteCategoryBudgetVariablesBuilder deleteCategoryBudget ({required String userId, required String categoryId, }) {
    return DeleteCategoryBudgetVariablesBuilder(dataConnect, userId: userId,categoryId: categoryId,);
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
