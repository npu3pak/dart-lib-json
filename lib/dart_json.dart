library dart_json;

import 'dart:convert';

class Json {

  dynamic raw;

  Json(raw) {
    if (raw is Json) {
      this.raw = raw.raw;
    } else {
      this.raw = raw;
    }
  }

  Json.fromString(String value) {
    raw = jsonDecode(value);
  }

  Json.object() {
    final Map<String, dynamic> empty = {};
    raw = empty;
  }

  Json.list(List<Json> items) {
    raw = items;
  }

  String toString() {
    return jsonEncode(raw, toEncodable: (value) {
      if (value is Json) {
        return value.raw;
      } else {
        return value;
      }
    });
  }

  // Dynamic

  dynamic get dynamicValue => raw;

  set dynamicValue(dynamic value) => raw = value;

  // Int

  int get intValue => raw;

  set intValue(int value) => raw = value;

  // String

  String get stringValue => raw;

  set stringValue(String value) => raw = value;

  // Map

  Json operator [](String key) {
    if (raw is Map<String, dynamic> == false) {
      throw Exception();
    }

    Map<String, dynamic> map = raw;
    if (map.containsKey(key)){
      final value = raw[key];
      if (value is Json) {
        return value;
      } else {
        return Json(raw[key]);
      }
    } else {
      map[key] = Json.object();
      return map[key];
    }
  }

  void operator []=(String key, Json value) {
    if (raw is Map<String, dynamic> == false) {
      throw Exception();
    }

    raw[key] = value;
  }

// List

  List<Json> get list {
    final List<dynamic> list = raw;
    return list.map((jsonItem) => Json(jsonItem)).toList();
  }

  set list(List<Json> value) => raw = value;
}