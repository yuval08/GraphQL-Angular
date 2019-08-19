import 'dart:convert';

abstract class GQLArgument {
  final String argumentID;
  final _values = List<GQLArgumentValue>();
  dynamic _value;
  GQLArgumentType _valueType;

  GQLArgument(this.argumentID);

  void addValue(String name, dynamic value, GQLArgumentType type) {
    if (value == null) return;
    _values.add(GQLArgumentValue(name, value, type));
  }

  void setValue(dynamic value, GQLArgumentType type) {
    _value = value;
    _valueType = type;
  }

  void prepare() {}

  void clear() {
    _value = null;
    _valueType = null;
    _values.clear();
  }

  bool isValidArgument() => _values.isNotEmpty || _value != null;

  @override
  String toString({bool withID = true}) {
    prepare();
    if (_values.isEmpty && _value == null) return "";
    if (_values.isNotEmpty && _value != null) {
      var err = 'Argument $argumentID has a value and values collection!';
      print(err);
      throw Exception(err);
    }
    var buffer = StringBuffer();
    if (withID) buffer.write(" $argumentID: ");
    if (_values.isNotEmpty) _writeArguments(buffer);
    if (_value != null) _writeArgumentValue(buffer, _value, _valueType);
    buffer.write(" ");
    return buffer.toString();
  }

  void _writeArguments(StringBuffer buffer) {
    buffer.write("{");
    _values.forEach((arg) {
      buffer.write(" ${arg.name}: ");
      _writeArgumentValue(buffer, arg.value, arg.type);
    });
    buffer.write("}");
  }

  void _writeArgumentValue(StringBuffer buffer, dynamic value, GQLArgumentType type) {
    switch (type) {
      case GQLArgumentType.BOOLEAN:
      case GQLArgumentType.INT:
      case GQLArgumentType.DOUBLE:
        buffer.write(json.encode(value));
        break;
      case GQLArgumentType.STRING:
        buffer.write(_stringToValue(value));
        break;
      case GQLArgumentType.ENUM:
        buffer.write(_enumToValue(value));
        break;
      case GQLArgumentType.DATETIME:
        buffer.write(_dateToValue(value));
        break;
      case GQLArgumentType.ARGUMENT:
        buffer.write((value as GQLArgument).toString(withID: false));
        break;
      case GQLArgumentType.STRING_LIST:
      case GQLArgumentType.INT_LIST:
      case GQLArgumentType.ENUM_LIST:
      case GQLArgumentType.ARGUMENT_LIST:
        buffer.write("[");
        var list = value as List;
        for (int i = 0; i < list.length; i++) {
          if (i > 0) buffer.write(", ");
          switch (type) {
            case GQLArgumentType.STRING_LIST:
              buffer.write(_stringToValue(list[i]));
              break;
            case GQLArgumentType.INT_LIST:
              buffer.write(list[i]);
              break;
            case GQLArgumentType.ENUM_LIST:
              buffer.write(_enumToValue(list[i]));
              break;
            case GQLArgumentType.ARGUMENT_LIST:
              buffer.write((list[i] as GQLArgument).toString(withID: false));
              break;
            default:
              break;
          }
        }
        buffer.write("]");
        break;
    }
  }

  String _stringToValue(String value) => json.encode(value);

  String _enumToValue(dynamic value) {
    value = value.toString();
    return value.substring(value.indexOf('.') + 1);
  }

  String _dateToValue(DateTime value) => json.encode("${value.year.toString()}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}T00:00:00Z");
}

class GQLArgumentValue {
  final GQLArgumentType type;
  final String name;
  final dynamic value;

  GQLArgumentValue(this.name, this.value, this.type);
}

enum GQLArgumentType { BOOLEAN, STRING, INT, DOUBLE, DATETIME, ENUM, ARGUMENT, STRING_LIST, INT_LIST, ENUM_LIST, ARGUMENT_LIST }
