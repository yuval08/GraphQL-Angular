import 'package:graphql_angular/GraphQL_Angular.dart';

class GQLObject extends GQLBaseField {
  final String name;
  final List<GQLBaseField> fields = List<GQLBaseField>();
  Function parseData;
  String alias;
  Object value;

  List<GQLArgument> arguments = List<GQLArgument>();

  void addArgument(GQLArgument arg) => arguments.add(arg);

  void addField(GQLBaseField field) => fields.add(field);

  void addFields(List<GQLBaseField> fields) => this.fields.addAll(fields);

  void addFieldByID(String field) => fields.add(GQLField(field));

  void addFieldsByID(List<String> fields) => fields.forEach((field) => addField(GQLField(field)));

  GQLObject(this.name, {this.parseData, this.alias}) : super(name: name);

}