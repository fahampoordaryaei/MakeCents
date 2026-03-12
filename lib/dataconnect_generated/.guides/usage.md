# Basic Usage

```dart
ExampleConnector.instance.ListUserTransactions(listUserTransactionsVariables).execute();
ExampleConnector.instance.GetUserPoints(getUserPointsVariables).execute();
ExampleConnector.instance.AddTransaction(addTransactionVariables).execute();
ExampleConnector.instance.SeedMakeCentsDatabase().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await ExampleConnector.instance.AddTransaction({ ... })
.description(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

