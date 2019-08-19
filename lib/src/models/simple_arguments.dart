import 'package:graphql_angular/GraphQL_Angular.dart';
import 'package:meta/meta.dart';

class IDArgument extends GQLArgument {
  final String id;

  IDArgument(this.id) : super("id") {
    setValue(id, GQLArgumentType.STRING);
  }
}

class IDListArgument extends GQLArgument {
  final List<String> ids;

  IDListArgument(this.ids) : super("id") {
    setValue(ids, GQLArgumentType.STRING_LIST);
  }
}

class FilterStringListArgument extends GQLArgument {
  final List<String> filter;

  FilterStringListArgument(this.filter) : super("filter") {
    setValue(filter, GQLArgumentType.STRING_LIST);
  }
}

class SimpleArgument extends GQLArgument {
  SimpleArgument({@required String id, @required dynamic value, GQLArgumentType type = GQLArgumentType.STRING}) : super(id) {
    setValue(value, type);
  }
}

class GQLArgumentList extends GQLArgument {
  final List<dynamic> list;

  GQLArgumentList({@required String id, @required this.list}) : super(id) {
    setValue(list, GQLArgumentType.ARGUMENT_LIST);
  }
}