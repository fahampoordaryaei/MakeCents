# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### ListInstitutions
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listInstitutions().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListInstitutionsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listInstitutions();
ListInstitutionsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listInstitutions().ref();
ref.execute();

ref.subscribe(...);
```


### ListCourses
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listCourses().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListCoursesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listCourses();
ListCoursesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listCourses().ref();
ref.execute();

ref.subscribe(...);
```


### ListUserTransactions
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.listUserTransactions(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListUserTransactionsData, ListUserTransactionsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listUserTransactions(
  userId: userId,
);
ListUserTransactionsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.listUserTransactions(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetUserPoints
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.getUserPoints(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetUserPointsData, GetUserPointsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getUserPoints(
  userId: userId,
);
GetUserPointsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.getUserPoints(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListProducts
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listProducts().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListProductsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listProducts();
ListProductsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listProducts().ref();
ref.execute();

ref.subscribe(...);
```


### ListRedeemedProducts
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.listRedeemedProducts(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListRedeemedProductsData, ListRedeemedProductsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listRedeemedProducts(
  userId: userId,
);
ListRedeemedProductsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.listRedeemedProducts(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListCurrencies
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listCurrencies().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListCurrenciesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listCurrencies();
ListCurrenciesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listCurrencies().ref();
ref.execute();

ref.subscribe(...);
```


### GetCountryIdByCode
#### Required Arguments
```dart
String code = ...;
ExampleConnector.instance.getCountryIdByCode(
  code: code,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetCountryIdByCodeData, GetCountryIdByCodeVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getCountryIdByCode(
  code: code,
);
GetCountryIdByCodeData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String code = ...;

final ref = ExampleConnector.instance.getCountryIdByCode(
  code: code,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetUserProfile
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.getUserProfile(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetUserProfileData, GetUserProfileVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getUserProfile(
  userId: userId,
);
GetUserProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.getUserProfile(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListScholarships
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listScholarships().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListScholarshipsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listScholarships();
ListScholarshipsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listScholarships().ref();
ref.execute();

ref.subscribe(...);
```


### ListExpenseCategories
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listExpenseCategories().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListExpenseCategoriesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listExpenseCategories();
ListExpenseCategoriesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listExpenseCategories().ref();
ref.execute();

ref.subscribe(...);
```


### GetLoginStatus
#### Required Arguments
```dart
String email = ...;
ExampleConnector.instance.getLoginStatus(
  email: email,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetLoginStatusData, GetLoginStatusVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getLoginStatus(
  email: email,
);
GetLoginStatusData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String email = ...;

final ref = ExampleConnector.instance.getLoginStatus(
  email: email,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListUserCategoryBudgets
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.listUserCategoryBudgets(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListUserCategoryBudgetsData, ListUserCategoryBudgetsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listUserCategoryBudgets(
  userId: userId,
);
ListUserCategoryBudgetsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.listUserCategoryBudgets(
  userId: userId,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### AddTransaction
#### Required Arguments
```dart
String userId = ...;
String categoryId = ...;
double amount = ...;
DateTime date = ...;
ExampleConnector.instance.addTransaction(
  userId: userId,
  categoryId: categoryId,
  amount: amount,
  date: date,
).execute();
```

#### Optional Arguments
We return a builder for each query. For AddTransaction, we created `AddTransactionBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AddTransactionVariablesBuilder {
  ...
   AddTransactionVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.addTransaction(
  userId: userId,
  categoryId: categoryId,
  amount: amount,
  date: date,
)
.description(description)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<AddTransactionData, AddTransactionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.addTransaction(
  userId: userId,
  categoryId: categoryId,
  amount: amount,
  date: date,
);
AddTransactionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String categoryId = ...;
double amount = ...;
DateTime date = ...;

final ref = ExampleConnector.instance.addTransaction(
  userId: userId,
  categoryId: categoryId,
  amount: amount,
  date: date,
).ref();
ref.execute();
```


### StoreUserProfile
#### Required Arguments
```dart
String userId = ...;
String email = ...;
String firstName = ...;
String lastName = ...;
ExampleConnector.instance.storeUserProfile(
  userId: userId,
  email: email,
  firstName: firstName,
  lastName: lastName,
).execute();
```

#### Optional Arguments
We return a builder for each query. For StoreUserProfile, we created `StoreUserProfileBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class StoreUserProfileVariablesBuilder {
  ...
   StoreUserProfileVariablesBuilder institutionId(String? t) {
   _institutionId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder courseId(String? t) {
   _courseId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder otherSchool(String? t) {
   _otherSchool.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder otherCourse(String? t) {
   _otherCourse.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder budget(double? t) {
   _budget.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder countryId(int? t) {
   _countryId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder currencyId(int? t) {
   _currencyId.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder isWeekly(bool? t) {
   _isWeekly.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder prefix(String? t) {
   _prefix.value = t;
   return this;
  }
  StoreUserProfileVariablesBuilder phoneNumber(String? t) {
   _phoneNumber.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.storeUserProfile(
  userId: userId,
  email: email,
  firstName: firstName,
  lastName: lastName,
)
.institutionId(institutionId)
.courseId(courseId)
.otherSchool(otherSchool)
.otherCourse(otherCourse)
.budget(budget)
.countryId(countryId)
.currencyId(currencyId)
.isWeekly(isWeekly)
.prefix(prefix)
.phoneNumber(phoneNumber)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<StoreUserProfileData, StoreUserProfileVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.storeUserProfile(
  userId: userId,
  email: email,
  firstName: firstName,
  lastName: lastName,
);
StoreUserProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String email = ...;
String firstName = ...;
String lastName = ...;

final ref = ExampleConnector.instance.storeUserProfile(
  userId: userId,
  email: email,
  firstName: firstName,
  lastName: lastName,
).ref();
ref.execute();
```


### DeleteTransaction
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deleteTransaction(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteTransactionData, DeleteTransactionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteTransaction(
  id: id,
);
DeleteTransactionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deleteTransaction(
  id: id,
).ref();
ref.execute();
```


### UpdateTransaction
#### Required Arguments
```dart
String id = ...;
String categoryId = ...;
double amount = ...;
DateTime date = ...;
ExampleConnector.instance.updateTransaction(
  id: id,
  categoryId: categoryId,
  amount: amount,
  date: date,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpdateTransaction, we created `UpdateTransactionBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpdateTransactionVariablesBuilder {
  ...
   UpdateTransactionVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.updateTransaction(
  id: id,
  categoryId: categoryId,
  amount: amount,
  date: date,
)
.description(description)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpdateTransactionData, UpdateTransactionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateTransaction(
  id: id,
  categoryId: categoryId,
  amount: amount,
  date: date,
);
UpdateTransactionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String categoryId = ...;
double amount = ...;
DateTime date = ...;

final ref = ExampleConnector.instance.updateTransaction(
  id: id,
  categoryId: categoryId,
  amount: amount,
  date: date,
).ref();
ref.execute();
```


### DeleteUserProfile
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.deleteUserProfile(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteUserProfileData, DeleteUserProfileVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteUserProfile(
  userId: userId,
);
DeleteUserProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.deleteUserProfile(
  userId: userId,
).ref();
ref.execute();
```


### UpdateUserBudget
#### Required Arguments
```dart
String userId = ...;
double budget = ...;
ExampleConnector.instance.updateUserBudget(
  userId: userId,
  budget: budget,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpdateUserBudget, we created `UpdateUserBudgetBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpdateUserBudgetVariablesBuilder {
  ...
   UpdateUserBudgetVariablesBuilder isWeekly(bool? t) {
   _isWeekly.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.updateUserBudget(
  userId: userId,
  budget: budget,
)
.isWeekly(isWeekly)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpdateUserBudgetData, UpdateUserBudgetVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateUserBudget(
  userId: userId,
  budget: budget,
);
UpdateUserBudgetData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
double budget = ...;

final ref = ExampleConnector.instance.updateUserBudget(
  userId: userId,
  budget: budget,
).ref();
ref.execute();
```


### UpdateUserCurrency
#### Required Arguments
```dart
String userId = ...;
int currencyId = ...;
ExampleConnector.instance.updateUserCurrency(
  userId: userId,
  currencyId: currencyId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateUserCurrencyData, UpdateUserCurrencyVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateUserCurrency(
  userId: userId,
  currencyId: currencyId,
);
UpdateUserCurrencyData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
int currencyId = ...;

final ref = ExampleConnector.instance.updateUserCurrency(
  userId: userId,
  currencyId: currencyId,
).ref();
ref.execute();
```


### InitPointsBalance
#### Required Arguments
```dart
String userId = ...;
int totalPoints = ...;
ExampleConnector.instance.initPointsBalance(
  userId: userId,
  totalPoints: totalPoints,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<InitPointsBalanceData, InitPointsBalanceVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.initPointsBalance(
  userId: userId,
  totalPoints: totalPoints,
);
InitPointsBalanceData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
int totalPoints = ...;

final ref = ExampleConnector.instance.initPointsBalance(
  userId: userId,
  totalPoints: totalPoints,
).ref();
ref.execute();
```


### UpdatePointsBalance
#### Required Arguments
```dart
String id = ...;
int totalPoints = ...;
ExampleConnector.instance.updatePointsBalance(
  id: id,
  totalPoints: totalPoints,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdatePointsBalanceData, UpdatePointsBalanceVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updatePointsBalance(
  id: id,
  totalPoints: totalPoints,
);
UpdatePointsBalanceData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
int totalPoints = ...;

final ref = ExampleConnector.instance.updatePointsBalance(
  id: id,
  totalPoints: totalPoints,
).ref();
ref.execute();
```


### RecordFailedLogin
#### Required Arguments
```dart
String userId = ...;
int failedAttempts = ...;
ExampleConnector.instance.recordFailedLogin(
  userId: userId,
  failedAttempts: failedAttempts,
).execute();
```

#### Optional Arguments
We return a builder for each query. For RecordFailedLogin, we created `RecordFailedLoginBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class RecordFailedLoginVariablesBuilder {
  ...
   RecordFailedLoginVariablesBuilder lockedUntil(Timestamp? t) {
   _lockedUntil.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.recordFailedLogin(
  userId: userId,
  failedAttempts: failedAttempts,
)
.lockedUntil(lockedUntil)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<RecordFailedLoginData, RecordFailedLoginVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.recordFailedLogin(
  userId: userId,
  failedAttempts: failedAttempts,
);
RecordFailedLoginData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
int failedAttempts = ...;

final ref = ExampleConnector.instance.recordFailedLogin(
  userId: userId,
  failedAttempts: failedAttempts,
).ref();
ref.execute();
```


### ResetLoginAttempts
#### Required Arguments
```dart
String userId = ...;
ExampleConnector.instance.resetLoginAttempts(
  userId: userId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<ResetLoginAttemptsData, ResetLoginAttemptsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.resetLoginAttempts(
  userId: userId,
);
ResetLoginAttemptsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;

final ref = ExampleConnector.instance.resetLoginAttempts(
  userId: userId,
).ref();
ref.execute();
```


### UpsertCategoryBudget
#### Required Arguments
```dart
String userId = ...;
String categoryId = ...;
int budgetAmount = ...;
ExampleConnector.instance.upsertCategoryBudget(
  userId: userId,
  categoryId: categoryId,
  budgetAmount: budgetAmount,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpsertCategoryBudgetData, UpsertCategoryBudgetVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.upsertCategoryBudget(
  userId: userId,
  categoryId: categoryId,
  budgetAmount: budgetAmount,
);
UpsertCategoryBudgetData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String categoryId = ...;
int budgetAmount = ...;

final ref = ExampleConnector.instance.upsertCategoryBudget(
  userId: userId,
  categoryId: categoryId,
  budgetAmount: budgetAmount,
).ref();
ref.execute();
```


### DeleteCategoryBudget
#### Required Arguments
```dart
String userId = ...;
String categoryId = ...;
ExampleConnector.instance.deleteCategoryBudget(
  userId: userId,
  categoryId: categoryId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteCategoryBudgetData, DeleteCategoryBudgetVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteCategoryBudget(
  userId: userId,
  categoryId: categoryId,
);
DeleteCategoryBudgetData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String categoryId = ...;

final ref = ExampleConnector.instance.deleteCategoryBudget(
  userId: userId,
  categoryId: categoryId,
).ref();
ref.execute();
```


### seedData
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.seedData().execute();
```



#### Return Type
`execute()` returns a `OperationResult<seedDataData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.seedData();
seedDataData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.seedData().ref();
ref.execute();
```


### seedLocationData
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.seedLocationData().execute();
```



#### Return Type
`execute()` returns a `OperationResult<seedLocationDataData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.seedLocationData();
seedLocationDataData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.seedLocationData().ref();
ref.execute();
```

