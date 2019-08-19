// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    type: json['type'] as String,
    id: json['id'] as String,
    payload: json['payload'],
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'payload': instance.payload,
    };

ConnectionMessage _$ConnectionMessageFromJson(Map<String, dynamic> json) {
  return ConnectionMessage(
    message: json['message'] as String,
  );
}

Map<String, dynamic> _$ConnectionMessageToJson(ConnectionMessage instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

Payload _$PayloadFromJson(Map<String, dynamic> json) {
  return Payload(
    query: json['query'] as String,
    operationName: json['operationName'] as String,
    variables: json['variables'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'operationName': instance.operationName,
      'query': instance.query,
      'variables': instance.variables,
    };
