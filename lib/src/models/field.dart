abstract class GQLBaseField {
  final String name;

  GQLBaseField({this.name});
}

class GQLField extends GQLBaseField {
  GQLField(String name) : super(name: name);
}

