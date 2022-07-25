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

class JsonValueException extends JsonException {
  /// The actual value of the JSON field. It is not exposed via the toString() method.
  final dynamic value;

  JsonValueException({
    required this.value,
    required String message,
    Exception? cause,
  }) : super(message, cause);

  JsonValueException._required({
    required String typeName,
    required String keyPath,
    required this.value,
  }) : super(
          """Unable to parse the required value at [$keyPath]. The internal value of JSON must be $typeName, but it's ${value == null ? "null" : value.runtimeType}.""",
        );

  JsonValueException._nullable({
    required String typeName,
    required String keyPath,
    required this.value,
  }) : super(
          """Unable to parse the value at [$keyPath]. The internal value of JSON must be $typeName, but it's ${value.runtimeType}.""",
        );

  JsonValueException._set({
    required String typeName,
    required String key,
    required String keyPath,
    required this.value,
  }) : super(
          """Unable to set a value with "$key" key. The JSON at [$keyPath] path must be $typeName, but it's ${value.runtimeType}.""",
        );
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

  // Type check

  bool isOf<T>() {
    return _raw is T;
  }

  bool isNotOf<T>() {
    return _raw is! T;
  }

  // Dynamic

  // ignore: unnecessary_getters_setters
  dynamic get dynamicValue => _raw;

  // ignore: unnecessary_getters_setters
  set dynamicValue(dynamic value) => _raw = value;

  // Num

  num get numOrException {
    if (_raw is num) {
      return _raw;
    } else {
      throw JsonValueException._required(
        typeName: "a num",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  num? get numValue {
    if (_raw is num || _raw == null) {
      return _raw;
    } else {
      throw JsonValueException._nullable(
        typeName: "a num",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  set numValue(num? value) => _raw = value;

  // Int

  int get intOrException {
    if (_raw is int) {
      return _raw;
    } else {
      throw JsonValueException._required(
        typeName: "an int",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  int? get intValue {
    if (_raw is int || _raw == null) {
      return _raw;
    } else {
      throw JsonValueException._nullable(
        typeName: "an int",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  set intValue(int? value) => _raw = value;

  // Double

  double get doubleOrException {
    if (_raw is double) {
      return _raw;
    } else {
      throw JsonValueException._required(
        typeName: "a double",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  double? get doubleValue {
    if (_raw is double || _raw == null) {
      return _raw;
    } else {
      throw JsonValueException._nullable(
        typeName: "a double",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  set doubleValue(double? value) => _raw = value;

  // String

  String get stringOrException {
    if (_raw is String) {
      return _raw;
    } else {
      throw JsonValueException._required(
        typeName: "a String",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  String? get stringValue {
    if (_raw is String || _raw == null) {
      return _raw;
    } else {
      throw JsonValueException._nullable(
        typeName: "a String",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  set stringValue(String? value) => _raw = value;

  // Bool

  bool get boolOrException {
    if (_raw is bool) {
      return _raw;
    } else {
      throw JsonValueException._required(
        typeName: "a bool",
        keyPath: _keyPath,
        value: _raw,
      );
    }
  }

  bool? get boolValue {
    if (_raw is bool || _raw == null) {
      return _raw;
    } else {
      throw JsonValueException._nullable(
        typeName: "a bool",
        keyPath: _keyPath,
        value: _raw,
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

    if (_raw is! Map<String, Json>) {
      throw JsonValueException._nullable(
        typeName: "a Map<String, Json>",
        keyPath: _keyPath,
        value: _raw,
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
    if (_raw is! Map<String, Json>) {
      throw JsonValueException._set(
        typeName: "an Object with Map<String, Json> internal type",
        key: key,
        keyPath: _keyPath,
        value: _raw,
      );
    }

    Map<String, Json> map = _raw;
    map[key] = value;
    map[key]!._keyPath = "$_keyPath/$key";
    map[key]!._isOptional = _isOptional;
  }

  // List

  List<Json> get list {
    if (_raw is! List<Json>) {
      throw JsonValueException._nullable(
        typeName: "an Array type with List<Json> internal type",
        keyPath: _keyPath,
        value: _raw,
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
