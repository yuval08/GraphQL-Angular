import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:graphql_angular/GraphQL_Angular.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

class Subscription {
  static String ConnectionInitialize = "connection_init";
  static String ConnectionOk = "connection_ack";
  static String ConnectionError = "connection_error";
  static String ConnectionKeepAlive = "ka";

  static String CommandTerminate = "connection_terminate";
  static String CommandStart = "start";
  static String CommandStop = "stop";

  static String ReturnTypeData = "data";
  static String ReturnTypeError = "error";
  static String ReturnTypeComplete = "complete";
}

@JsonSerializable()
class Message {
  final String id;
  final String type;
  final dynamic payload;

  Message({this.type, this.id, this.payload});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
  String jsonEncode() => json.encode(toJson());
}

@JsonSerializable()
class ConnectionMessage {
  final String message;

  ConnectionMessage({@required this.message});

  factory ConnectionMessage.fromJson(Map<String, dynamic> json) => _$ConnectionMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectionMessageToJson(this);
}

@JsonSerializable()
class Payload {
  final String operationName;
  final String query;
  final Map<String, dynamic> variables;

  Payload({@required this.query, this.operationName, this.variables});

  factory Payload.fromJson(Map<String, dynamic> json) => _$PayloadFromJson(json);
  Map<String, dynamic> toJson() => _$PayloadToJson(this);
}

class SubscriptionError {
  final GQLSubscriptionErrorType type;
  final List<String> messages;

  SubscriptionError({@required this.type, @required this.messages});
}
