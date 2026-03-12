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

## Mutations

### AddTransaction
#### Required Arguments
```dart
String userId = ...;
String category = ...;
double amount = ...;
DateTime date = ...;
ExampleConnector.instance.addTransaction(
  userId: userId,
  category: category,
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
  category: category,
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
  category: category,
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
String category = ...;
double amount = ...;
DateTime date = ...;

final ref = ExampleConnector.instance.addTransaction(
  userId: userId,
  category: category,
  amount: amount,
  date: date,
).ref();
ref.execute();
```


### SeedMakeCentsDatabase
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.seedMakeCentsDatabase().execute();
```



#### Return Type
`execute()` returns a `OperationResult<SeedMakeCentsDatabaseData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.seedMakeCentsDatabase();
SeedMakeCentsDatabaseData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.seedMakeCentsDatabase().ref();
ref.execute();
```

