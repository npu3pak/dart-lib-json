library dart_json;

import 'dart:convert';

class Json {

  dynamic raw;

  Json(this.raw);

  Json.fromString(String value) {
    this.raw = jsonDecode(value);
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
      map[key] = Json(null);
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

  List<Json> getList(String key) {
    final list = List<Map<String, dynamic>>.from(content[key]);
    return list.map((jsonItem) => Json(jsonItem)).toList();
  }
}