library dart_json;

import 'dart:convert';

abstract class JsonAdapter<T> {
  T? fromJson(Json json);

  Json toJson(T? value);
}

class JsonException implements Exception {
  final String message;
  final Exception? cause;

  JsonException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return '$message\n${cause.toString()}';
    } else {
      return message;
    }
  }
}

class Json {
  // Can be a null, a simple value, a List<Json>, or a Map<String, Json>.
  dynamic _raw;
  String _keyPath = "";
  bool _isOptional = false;

  // Constructors

  Json(dynamic raw) {
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
    _raw = <String, Json>{};
  }

  Json.list() {
    _raw = <Json>[];
  }

  // Key path

  String get keyPath => _keyPath.isEmpty ? "/" : _keyPath;

  // Serialization and deserialization

  Json.parse(String value) : this(_parse(value));

  static dynamic _parse(String value) {
    try {
      return jsonDecode(value);
    } on Exception catch (e) {
      throw JsonException("Unable to parse JSON.", e);
    }
  }

  String asString() {
    return asPrettyString(indent: null);
  }

  String asPrettyString({String? indent = "  "}) {
    final encoder = JsonEncoder.withIndent(indent, (value) {
      if (value is Json) {
        return value._raw;
      } else {
        return value;
      }
    });

    return encoder.convert(_raw);
  }

  // Optional

  /// This property returns JSON, for which access to objects
  /// by a nonexistent key will NOT result in an error,
  /// but will return another empty optional JSON.
  ///
  /// However, calling [list] on a nonexistent key for optional JSON
  /// will still fail. Items of [list] retrieved from the existing key
  /// will not inherit the optional attribute.

  Json get optional {
    final optionalClone = Json.empty();
    optionalClone._raw = _raw;
    optionalClone._keyPath = _keyPath;
    optionalClone._isOptional = true;
    return optionalClone;
  }

  bool get isOptional => _isOptional;

  // Existence check

  bool get isExist => _raw != null;

  // Num

  num? get numValue {
    if (_raw is num || _raw == null) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a num, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set numValue(num? value) => _raw = value;

  // Int

  int? get intValue {
    if (_raw is int || _raw == null) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a int, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set intValue(int? value) => _raw = value;

  // Double

  double? get doubleValue {
    if (_raw is double || _raw == null) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a double, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set doubleValue(double? value) => _raw = value;

  // String

  String? get stringValue {
    if (_raw is String || _raw == null) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a string, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set stringValue(String? value) => _raw = value;

  // Bool

  bool? get boolValue {
    if (_raw is bool || _raw == null) {
      return _raw;
    } else {
      throw JsonException(
        "Unable access a value at [$_keyPath]. The internal value of JSON must be a bool, but it's ${_raw.runtimeType}.",
      );
    }
  }

  set boolValue(bool? value) => _raw = value;

  // Map

  Json operator [](String key) {
    return _getMapValue(key);
  }

  Json _getMapValue(String key) {
    if (_raw == null && _isOptional) {
      final json = Json.empty();
      json._isOptional = true;
      json._keyPath = "$_keyPath/$key";
      return json;
    }

    if (_raw is Map<String, Json> == false) {
      throw JsonException(
        """Unable to access a value with "$key" key. The JSON at [$keyPath] path must be an Object with Map<String, Json> internal value type, but it's ${_raw.runtimeType}.""",
      );
    }

    Map<String, Json> map = _raw;

    if (map.containsKey(key)) {
      map[key]!._keyPath = "$_keyPath/$key";
      map[key]!._isOptional = _isOptional;
      return map[key]!;
    } else {
      map[key] = Json.empty();
      map[key]!._keyPath = "$_keyPath/$key";
      map[key]!._isOptional = _isOptional;
      return map[key]!;
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
    map[key]!._keyPath = "$_keyPath/$key";
    map[key]!._isOptional = _isOptional;
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

  T? get<T>(JsonAdapter<T> adapter) => adapter.fromJson(this);

  void set<T>(T? value, JsonAdapter<T> adapter) {
    _raw = adapter.toJson(value)._raw;
  }

  // Convenience

  static Json fromObjectList<T>(List<T>? list, Json Function(T item) builder) {
    if (list == null) {
      return Json.empty();
    }

    final listJson = Json.list();
    for (final T item in list) {
      listJson.list.add(builder(item));
    }
    return listJson;
  }

  List<T>? toObjectList<T>(T Function(Json j) builder) {
    if (_raw == null) {
      return null;
    }
    return list.map((j) => builder(j)).toList();
  }
}
