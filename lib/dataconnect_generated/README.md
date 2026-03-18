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

### ListSchools
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listSchools().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListSchoolsData, void>`
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

final result = await ExampleConnector.instance.listSchools();
ListSchoolsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listSchools().ref();
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


### GetUserProfile
#### Required Arguments
```dart
String username = ...;
ExampleConnector.instance.getUserProfile(
  username: username,
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
  username: username,
);
GetUserProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String username = ...;

final ref = ExampleConnector.instance.getUserProfile(
  username: username,
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
String username = ...;
String email = ...;
String firstName = ...;
String lastName = ...;
ExampleConnector.instance.storeUserProfile(
  username: username,
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
   StoreUserProfileVariablesBuilder schoolId(String? t) {
   _schoolId.value = t;
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
  StoreUserProfileVariablesBuilder monthlyBudget(double? t) {
   _monthlyBudget.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.storeUserProfile(
  username: username,
  email: email,
  firstName: firstName,
  lastName: lastName,
)
.schoolId(schoolId)
.courseId(courseId)
.otherSchool(otherSchool)
.otherCourse(otherCourse)
.monthlyBudget(monthlyBudget)
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
  username: username,
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
String username = ...;
String email = ...;
String firstName = ...;
String lastName = ...;

final ref = ExampleConnector.instance.storeUserProfile(
  username: username,
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
String username = ...;
ExampleConnector.instance.deleteUserProfile(
  username: username,
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
  username: username,
);
DeleteUserProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String username = ...;

final ref = ExampleConnector.instance.deleteUserProfile(
  username: username,
).ref();
ref.execute();
```


### UpdateUserBudget
#### Required Arguments
```dart
String username = ...;
double budget = ...;
ExampleConnector.instance.updateUserBudget(
  username: username,
  budget: budget,
).execute();
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
  username: username,
  budget: budget,
);
UpdateUserBudgetData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String username = ...;
double budget = ...;

final ref = ExampleConnector.instance.updateUserBudget(
  username: username,
  budget: budget,
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


### SeedFullData
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.seedFullData().execute();
```



#### Return Type
`execute()` returns a `OperationResult<SeedFullDataData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.seedFullData();
SeedFullDataData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.seedFullData().ref();
ref.execute();
```


### SeedProductsOnly
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.seedProductsOnly().execute();
```



#### Return Type
`execute()` returns a `OperationResult<SeedProductsOnlyData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.seedProductsOnly();
SeedProductsOnlyData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.seedProductsOnly().ref();
ref.execute();
```


### SeedOnboardingData
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.seedOnboardingData().execute();
```



#### Return Type
`execute()` returns a `OperationResult<SeedOnboardingDataData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.seedOnboardingData();
SeedOnboardingDataData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.seedOnboardingData().ref();
ref.execute();
```

