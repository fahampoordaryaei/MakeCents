# Basic Usage

```dart
ExampleConnector.instance.ListSchools().execute();
ExampleConnector.instance.ListCourses().execute();
ExampleConnector.instance.ListUserTransactions(listUserTransactionsVariables).execute();
ExampleConnector.instance.GetUserPoints(getUserPointsVariables).execute();
ExampleConnector.instance.AddTransaction(addTransactionVariables).execute();
ExampleConnector.instance.StoreUserProfile(storeUserProfileVariables).execute();
ExampleConnector.instance.DeleteTransaction(deleteTransactionVariables).execute();
ExampleConnector.instance.UpdateUserBudget(updateUserBudgetVariables).execute();
ExampleConnector.instance.GetUserProfile(getUserProfileVariables).execute();
ExampleConnector.instance.ListScholarships().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await ExampleConnector.instance.StoreUserProfile({ ... })
.schoolId(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

