import 'dart:convert';

import 'package:graphql_angular/GraphQL_Angular.dart';

class GQLQuery {
  final GQLQueryType type;
  final List<GQLObject> objects = List<GQLObject>();

  GQLQuery(this.type);

  void addObject(GQLObject obj) => objects.add(obj);

  String toString() {
    if (objects.isEmpty) {
      throw Exception("You need to define at least 1 GraphQLObject in order to generate a GraphQL $type");
    }
    var buffer = StringBuffer();
    if (type == GQLQueryType.Mutation) buffer.write("mutation");
    buffer.write(" { ");
    objects.forEach((obj) => _addObjectToBuffer(buffer, obj));
    buffer.write(" } ");
    return "{ \"query\": ${json.encode(buffer.toString())} } ";
  }

  void _addObjectToBuffer(StringBuffer buffer, GQLObject obj) {
    if (obj.alias != null) buffer.write("${obj.alias} : ");
    buffer.write(obj.name);
    _addArgumentsToBuffer(buffer, obj.arguments);
    _addFieldsToBuffer(buffer, obj.fields);
  }

  void _addArgumentsToBuffer(StringBuffer buffer, List<GQLArgument> arguments) {
    if (arguments.isEmpty) return;
    buffer.write(" ( ");
    arguments.forEach((arg) {
      buffer.write(arg.toString());
    });
    buffer.write(" ) ");
  }

  void _addFieldsToBuffer(StringBuffer buffer, List<GQLBaseField> fields) {
    if (fields.isEmpty) return;
    buffer.write(" { ");
    fields.forEach((field) => _addFieldToBuffer(buffer, field));
    buffer.write(" } ");
  }

  void _addFieldToBuffer(StringBuffer buffer, GQLBaseField field) {
    if (field is GQLField) {
      buffer.write("${field.name} ");
    } else if (field is GQLObject) {
      buffer.write("${field.name} ");
      _addArgumentsToBuffer(buffer, field.arguments);
      _addFieldsToBuffer(buffer, field.fields);
    }
  }

  void assignObjectsData(Map<String, dynamic> data) {
    objects.forEach((obj) {
      obj.value = obj.parseData(data[obj.alias == null || obj.alias.isEmpty ? obj.name : obj.alias]);
    });
  }

  dynamic getValue<T>(String name) {
    try {
      var aliasResult = objects.where((obj) => obj.alias == name);
      if (aliasResult.isEmpty) {
        var objectResult = objects.where((obj) => obj.name == name && obj.alias == null);
        if (objectResult.length == 1) return objectResult.first.value as T;
      } else {
        return aliasResult.first.value as T;
      }
    } catch (err) {
      print('Could not convert  $type object $name to type $T');
    }
    throw Exception("Object or alias \"$name\" was not found!");
  }
}
