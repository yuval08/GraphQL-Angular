class GQLError {
  int errorCode;
  List<String> errorMessages;

  GQLError(this.errorCode, this.errorMessages);

  factory GQLError.fromError(int errorCode, String errorMessage) => GQLError(errorCode, [errorMessage]);
  factory GQLError.fromErrors(int errorCode, List<String> errorMessages) => GQLError(errorCode, errorMessages);
}