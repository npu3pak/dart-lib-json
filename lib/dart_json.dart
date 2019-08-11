library dart_json;

import 'dart:convert';

class JsonException implements Exception {

  String _message;
  Exception _cause;

  JsonException.invalidJson([Exception cause]):
      _message = "Invalid JSON.",
      _cause = cause;

  JsonException.unsupportedType(dynamic value):
      _message = "Unsupported type ${value.runtimeType}.";

  JsonException.wrongTypeOfItem(dynamic value, String reason):
      _message = "Wrong type of item ${value.runtimeType}. $reason";

  JsonException.arrayOutOfBounds(int index, Exception cause):
      _message = "Array index $index out of bounds",
      _cause = cause;

  JsonException.dictionaryKeyNotExist(String key, Exception cause):
      _message = "Dictionary key $key not exist",
      _cause = cause;

  @override
  String toString() {
    if (_cause != null) {
      return _message + "\n" + _cause.toString();
    } else {
      return _message;
    }
  }
}

class Json {

  // Can be a simple value, a List<Json>, or a Map<String, Json>.
  dynamic _raw;

  // Constructors

  Json(raw) {
    if (_isSupportedValueType(raw)) {
      this._raw = raw;
    } else if (raw is Json) {
      this._raw = raw._raw;
    } else if (raw is Map<String, dynamic>) {
      final Map<String, dynamic> map = raw;
      this._raw = map.map((k,v) => MapEntry(k,Json(v)));
    } else if (raw is List<Json>) {
      this._raw = raw;
    } else if (raw is List<dynamic>) {
      final List<dynamic> list = raw;
      this._raw = list.map((v) => Json(v)).toList();
    } else {
      throw JsonException.unsupportedType(raw);
    }
  }

  bool _isSupportedValueType(dynamic value) {
    return value == null ||
      value is String ||
      value is num ||
      value is int ||
      value is double ||
      value is bool;
  }

  Json.empty(): this(null);

  Json.object() {
    final Map<String, dynamic> empty = {};
    _raw = empty;
  }

  Json.list() {
    _raw = List<Json>();
  }

  // Serialization and deserialization

  Json.parse(String value): this(jsonDecode(value));

  String asString() {
    return jsonEncode(_raw, toEncodable: (value) {
      if (value is Json) {
        return value._raw;
      } else {
        return value;
      }
    });
  }

  // Dynamic

  // ignore: unnecessary_getters_setters
  dynamic get dynamicValue => _raw;

  // ignore: unnecessary_getters_setters
  set dynamicValue(dynamic value) => _raw = value;

  // Int

  int get intValue => _raw;

  set intValue(int value) => _raw = value;

  // Double

  double get doubleValue => _raw;

  set doubleValue(double value) => _raw = value;

  // String

  String get stringValue => _raw;

  set stringValue(String value) => _raw = value;

  // Bool

  bool get boolValue => _raw;

  set boolValue(bool value) => _raw = value;

  // Map

  Json operator [](String key) {
    if (_raw is Map<String, dynamic> == false) {
      throw Exception();
    }

    Map<String, dynamic> map = _raw;
    if (map.containsKey(key)){
      final value = _raw[key];
      if (value is Json) {
        return value;
      } else {
        return Json(_raw[key]);
      }
    } else {
      map[key] = Json.object();
      return map[key];
    }
  }

  void operator []=(String key, Json value) {
    if (_raw is Map<String, dynamic> == false) {
      throw Exception();
    }

    _raw[key] = value;
  }

// List

  List<Json> get list {
    if (_raw is List<Json>) {
      return _raw;
    } else {
      throw Exception();
    }
  }

  set list(List<Json> value) => _raw = value;
}