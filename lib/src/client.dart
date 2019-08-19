import 'dart:convert';

import 'package:graphql_angular/GraphQL_Angular.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class GQLClient {
  final String url;
  final GQLQuery query;
  GQLError error;

  Map<String, String> headers;
  Map<String, dynamic> responseBody;

  GQLClient({@required this.url, @required GQLQueryType type, this.headers}) : query = GQLQuery(type) {
    if (headers == null) headers = Map<String, String>();
    headers['Content-Type'] = 'application/json';
  }

  void addObject(GQLObject obj) => query.objects.add(obj);

  dynamic getValue<T>(String name) => query.getValue<T>(name);

  Future<bool> send() async {
    error = null;

    try {
      //todo validate this in another place
//      if (appContext.token == null || appContext.token.isEmpty) {
//        error = GQLError.fromError(-4, "No session token found in application context. Authentication state: ${appContext.authenticationBloc?.currentState?.toString()}");
//        return false;
//      }
//      var headers = Map<String, String>();
//      headers[tokenName] = appContext.token;
//      headers['Content-Type'] = 'application/json';
      String body = query.toString();
      var response = await http.post(url, body: body, headers: headers);
      switch (response.statusCode) {
        case 200:
          responseBody = json.decode(utf8.decode(response.bodyBytes));
          var data = responseBody['data'];
          var errors = responseBody['errors'];
          if (errors != null) {
            error = _getGraphQLError(response.statusCode, errors);
            return false;
          }
          query.assignObjectsData(data);
          return true;
          break;
        case 422:
          error = _getGraphQLError(response.statusCode, json.decode(response.body)['errors']);
          return false;
          break;
        default:
          error = GQLError.fromError(-3, "An error has occurred when sending GraphQL request: ${response.statusCode}");
          break;
      }
    } catch (err) {
      error = GQLError.fromError(-1, "An error has occurred when sending GraphQL request: $err");
    }
    return false;
  }

  GQLError _getGraphQLError(int statusCode, List errors) {
    var errorList = List<String>();
    errors.forEach((err) => errorList.add(err['message'].toString()));
    return GQLError.fromErrors(statusCode, errorList);
  }
}
