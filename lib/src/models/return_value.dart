import 'package:graphql_angular/GraphQL_Angular.dart';

class ReturnValue<T> {
  final T returnValue;

  ReturnValue({this.returnValue});

  GQLError error;
  factory ReturnValue.fromError(GQLError error) => ReturnValue<T>()..error = error;
}
