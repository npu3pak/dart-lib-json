// @dart = 2.9

library dart_json;

import 'dart:convert';

abstract class JsonAdapter<T> {
  T fromJson(Json json);

  Json toJson(T value);
}

class JsonException implements Exception {
  JsonException(this._message, [this._cause]);

  final String _message;
  final Exception _cause;

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
  var _keyPath = "";

  // Constructors

  Json(raw) {
    if (_isSupportedValueType(raw)) {
      _raw = raw;
    } else if (raw is Json) {
      _raw = raw._raw;
    } else if (raw is Map<String, dynamic>) {
      final Map<String, dynamic> map = raw;
      _raw = map.map((k, v) => MapEntry(k, Json(v)));
    } else if (raw is List<Json>) {
      _raw = raw;
    } else if (raw is List<dynamic>) {
      final List<dynamic> list = raw;
      _raw = list.map((v) => Json(v)).toList();
    } else if (raw is Iterable<dynamic>) {
      final Iterable<dynamic> iterable = raw;
      _raw = iterable.map((v) => Json(v)).toList();
    } else {
      throw JsonException(
        "Can not create a JSON with type ${raw.runtimeType}.",
      );
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

  Json.empty() : this(null);

  Json.object() {
    final Map<String, Json> empty = {};
    _raw = empty;
  }

  Json.list() {
    _raw = <Json>[];
  }

  // Key path

  String get keyPath => _keyPath.isEmpty ? "/" : _keyPath;

  // Serialization and deserialization

  Json.parse(String value) : this(jsonDecode(value));

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

  // Existence check

  bool get isExist => _raw != null;

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
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a num, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set numValue(num value) => _raw = value;

  // Int

  int get intValue {
    if ((_raw is int) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a int, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set intValue(int value) => _raw = value;

  // Double

  double get doubleValue {
    if ((_raw is double) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a double, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set doubleValue(double value) => _raw = value;

  // String

  String get stringValue {
    if ((_raw is String) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a string, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set stringValue(String value) => _raw = value;

  // Bool

  bool get boolValue {
    if ((_raw is bool) || (_raw == null)) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a bool, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set boolValue(bool value) => _raw = value;

  // Map

  Json operator [](String key) {
    return _getMapValue(key);
  }

  Json _getMapValue(String key) {
    if (_raw is Map<String, Json> == false) {
      throw JsonException(
        """Unable to access a value with "$key" key. The JSON at [$keyPath] path must be an Object with Map<String, Json> internal value type, but it's ${_raw.runtimeType}.""",
      );
    }

    Map<String, Json> map = _raw;

    if (map.containsKey(key)) {
      map[key]._keyPath = "$_keyPath/$key";
      return map[key];
    } else {
      map[key] = Json.empty();
      map[key]._keyPath = "$_keyPath/$key";
      return map[key];
    }
  }

  void operator []=(String key, Json value) {
    if (_raw is Map<String, Json> == false) {
      throw JsonException(
        """Unable to set a value with "$key" key. The JSON at [$_keyPath] path must be an Object with Map<String, Json> internal type, but it's ${_raw.runtimeType}.""",
      );
    }

    Map<String, Json> map = _raw;
    map[key] = value;
    map[key]._keyPath = "$_keyPath/$key";
  }

  // List

  List<Json> get list {
    if (_raw is List<Json> == false) {
      throw JsonException(
        """Unable to cast the JSON value at [$_keyPath] to a list. The JSON must be an Array type with List<Json> internal type, but it's ${_raw.runtimeType}.""",
      );
    }

    List<Json> list = _raw;

    for (var i = 0; i < list.length; i++) {
      list[i]._keyPath = "$_keyPath/$i";
    }

    return list;
  }

  // Custom

  T get<T>(JsonAdapter<T> adapter) => adapter.fromJson(this);

  void set<T>(T value, JsonAdapter<T> adapter) =>
      _raw = adapter.toJson(value)?._raw;

  // Convenience

  static Json fromObjectList<T>(List<T> list, Json Function(T item) builder) {
    if (list == null) {
      return Json.empty();
    }

    final listJson = Json.list();
    for (final T item in list) {
      listJson.list.add(builder(item));
    }
    return listJson;
  }

  List<T> toObjectList<T>(T Function(Json j) builder) {
    if (_raw == null) {
      return null;
    }
    return list.map((j) => builder(j)).toList();
  }
}
