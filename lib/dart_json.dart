library dart_json;

import 'dart:convert';

abstract class JsonAdapter<T> {
  T fromJson(Json json);

  Json toJson(T value);
}

class JsonException implements Exception {
  JsonException(this._message, [this._cause]);

  String _message;
  Exception _cause;

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
      throw JsonException("Can not create a JSON with type ${raw.runtimeType}.");
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
    final Map<String, Json> empty = {};
    _raw = empty;
  }

  Json.list() {
    _raw = List<Json>();
  }

  // Serialization and deserialization

  Json.parse(String value): this(jsonDecode(value));

  String asString() {
    return asPrettyString(null);
  }

  String asPrettyString([String indent = '  ']) {
    final encoder = JsonEncoder.withIndent(indent, (value) {
      if (value is Json) {
        return value._raw;
      } else {
        return value;
      }
    });

    return encoder.convert(_raw);
  }

  // Dynamic

  // ignore: unnecessary_getters_setters
  dynamic get dynamicValue => _raw;

  // ignore: unnecessary_getters_setters
  set dynamicValue(dynamic value) => _raw = value;

  // Num

  num get numValue {
    if ((_raw is num) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException("Unable access a value. The internal value of JSON must be a num, but it's ${_raw.runtimeType}.");
    }
  }

  set numValue(dynamic value) {
    if ((value is double) || (value is num) || (value is int)) {
      _raw = (value as num);
      return;
    }
    if (value is String) {
      try {
        String stringValue = value;
        _raw = num.parse(stringValue.replaceAll(',', '.'));
      } catch(e) {
        throw JsonException("Unable to cast a value of ${_raw.runtimeType} to num");
      }
      return;
    }
    if (value == null) {
      _raw = null;
      return;
    }

    throw JsonException("Unable to cast a value of ${_raw.runtimeType} to num");
  }

  // Int

  int get intValue {
    if ((_raw is int) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException("Unable access a value. The internal value of JSON must be a int, but it's ${_raw.runtimeType}.");
    }
  }

  set intValue(dynamic value) {
    if (value is int) {
      _raw = value.toInt();
      return;
    }
    if ((value is double) || (value is num)) {
      if ((value as double).remainder(1) == 0) { // use this condition because double.toInt() just drop fractional part of a number
        _raw = value.toInt();
        return;
      }
    }
    if (value is String) {
      try {
        _raw = int.parse(value as String);
      } catch(e) {
        throw JsonException("Unable to cast a value of ${_raw.runtimeType} to int");
      }
      return;
    }
    if (value == null) {
      _raw = null;
      return;
    }

    throw JsonException("Unable to cast a value of ${_raw.runtimeType} to int");
  }

  // Double

  double get doubleValue {
    if ((_raw is double) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException("Unable access a value. The internal value of JSON must be a double, but it's ${_raw.runtimeType}.");
    }
  }

  set doubleValue(dynamic value) {
    if ((value is double) || (value is num) || (value is int)) {
      _raw = value.toDouble();
      return;
    }
    if (value is String) {
      try {
        String stringValue = value;
        _raw = double.parse(stringValue.replaceAll(',', '.'));
      } catch(e) {
        throw JsonException("Unable to cast a value of ${_raw.runtimeType} to double");
      }
      return;
    }
    if (value == null) {
      _raw = null;
      return;
    }

    throw JsonException("Unable to cast a value of ${_raw.runtimeType} to double");
  }

  // String

  String get stringValue {
    if ((_raw is String) || (_raw == null)) {
      return _raw;
    } else if ((_raw is num) || (_raw is double) || (_raw is int)) {
      return "$_raw";
    } else {
      throw JsonException("Unable access a value. The internal value of JSON must be a string, but it's ${_raw.runtimeType}.");
    }
  }

  set stringValue(String value) => _raw = value;

  // Bool

  bool get boolValue {
    if ((_raw is bool) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException("Unable access a value. The internal value of JSON must be a bool, but it's ${_raw.runtimeType}.");
    }
  }

  set boolValue(bool value) => _raw = value;

  // Map

  Json operator [](String key) {
    return _getMapValue(key);
  }

  Json _getMapValue(String key) {
    if (_raw is Map<String, Json> == false) {
      final reason = """
Unable to access a value at "$key" key. The JSON must be an Object type with Map<String, Json> internal value type, but it's ${_raw
      .runtimeType}.""";
      throw JsonException(reason);
    }

    Map<String, Json> map = _raw;

    if (map.containsKey(key)){
      return map[key];
    } else {
      map[key] = Json.object();
      return map[key];
    }
  }

  void operator []=(String key, Json value) {
    if (_raw is Map<String, Json> == false) {
      final reason = """
Unable to set a value at "$key" key. The JSON must be an Object type with Map<String, Json> internal value type, but it's ${_raw
        .runtimeType}.""";
      throw JsonException(reason);
    }

    Map<String, Json> map = _raw;
    map[key] = value;
  }

  // List

  List<Json> get list {
    if (_raw is List<Json> == false) {
      final reason = """
Unable to cast the JSON value to a list. The JSON must be an Array type with List<Json> internal value type, but it's ${_raw
        .runtimeType}.""";
      throw JsonException(reason);
    }

    List<Json> list = _raw;
    return list;
  }

  // Custom

  T get<T>(JsonAdapter<T> adapter) => adapter.fromJson(this);

  void set<T>(T value, JsonAdapter<T> adapter) => _raw = adapter.toJson(value)?._raw;
}