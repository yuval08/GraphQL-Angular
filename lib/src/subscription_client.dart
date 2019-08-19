import 'dart:async';
import 'dart:convert';
import 'package:graphql_angular/src/models/subscription.dart';
import 'package:meta/meta.dart';
import 'dart:html';

import 'package:graphql_angular/GraphQL_Angular.dart';

class SubscriptionClient<T> {
  final String url;
  final String id;
  final String query;
  final Map<String, dynamic> variables;
  final Function parseData;

  WebSocket _socket;

  SubscriptionClient({@required this.url, @required this.id, @required this.query, this.variables, @required this.parseData});

  Future connect() async {
    try {
      _socket = await WebSocket(url, ["graphql-ws"]);
      _socket.onMessage.listen((data) => _onMessage(data));
      _socket.onClose.listen((data) => _onClose(data));
      _socket.onError.listen((data) => _onError(data));
      _socket.onOpen.listen((data) => _onOpen(data));
    } catch (ex) {
      _onErrorEvent.add(SubscriptionError(type: GQLSubscriptionErrorType.Connection, messages: [ex]));
    }
  }

  Stream<SubscriptionError> get onError => _onErrorEvent.stream;
  final _onErrorEvent = StreamController<SubscriptionError>();

  Stream<T> get onReceive => _onReceiveEvent.stream;
  final _onReceiveEvent = StreamController<T>();

  Stream get onComplete => _onCompleteEvent.stream;
  final _onCompleteEvent = StreamController();

  void _onMessage(MessageEvent e) {
    var response = Message.fromJson(json.decode(e.data));
    switch (response.type) {
      case "ka": //Subscription.ConnectionKeepAlive:
        break;
      case "connection_ack": //Subscription.ConnectionOk:
        _onMessageOk();
        break;
      case "data": //Subscription.ReturnTypeData:
        _onReturnTypeData(response.payload['data'][id]);
        break;
      case "complete": //Subscription.ReturnTypeComplete:
        _onReturnTypeComplete();
        break;
      case "error": //Subscription.ReturnTypeError:
        _onReturnTypeError(response.payload as List<dynamic>);
        break;
      case "connection_error": //Subscription.ConnectionError:
        _onErrorMessage(ConnectionMessage.fromJson(response.payload).message);
        break;
      default:
        _unhandledType(response.type);
        break;
    }
  }

  Future _onMessageOk() async {
    try {
      var payload = Payload(query: query, variables: variables);
      var message = Message(id: id, type: Subscription.CommandStart, payload: payload.toJson());
      var requestString = json.encode(message.toJson());
      await _socket.sendString(requestString);
    }
    catch (ex) {
      await _onErrorMessage('Command Start Error: $ex');
    }
  }

  void _onReturnTypeData(data) {
    _onReceiveEvent.add(parseData(data));
  }

  Future _onReturnTypeComplete() async {
    _onCompleteEvent.add(1);
    await disconnect();
  }

  Future _onReturnTypeError(List errors) async {
    _onErrorEvent.add(SubscriptionError(messages: errors.map((e) => e['message']).toList(), type: GQLSubscriptionErrorType.GQLError));
    await disconnect();
  }

  Future _unhandledType(String type) async {
    _onErrorEvent.add(SubscriptionError(type: GQLSubscriptionErrorType.UnhandledResponseType, messages: ['Unhandled type: $type']));
    await disconnect();
  }

  Future _onErrorMessage(String message) async {
    _onErrorEvent.add(SubscriptionError(type: GQLSubscriptionErrorType.Subscription, messages: [message]));
    await disconnect();
  }

  void _onClose(CloseEvent e) {
    print('Close Event');
  }

  void _onError(Event e) {
    print('Error Event');
    _onErrorEvent.add(SubscriptionError(type: GQLSubscriptionErrorType.SocketError, messages: ['Socket error']));
  }

  Future _onOpen(Event data) async {
    print('Open Event');
    await _socket.sendString(Message(type: Subscription.ConnectionInitialize).jsonEncode());
  }

  Future disconnect() async {
    await stop();
    try {
      var request = Message(type: Subscription.CommandTerminate);
      await _socket.sendString(request.jsonEncode());
    }
    catch (ex) {
      _onErrorEvent.add(SubscriptionError(type: GQLSubscriptionErrorType.Disconnect, messages: [ex]));
    }
  }

  Future stop() async {
    try {
      var request = Message(type: Subscription.CommandStop);
      await _socket.sendString(request.jsonEncode());
    }
    catch (ex) {
      _onErrorEvent.add(SubscriptionError(type: GQLSubscriptionErrorType.Stop, messages: [ex]));
    }
  }
}
