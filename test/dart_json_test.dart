import 'package:flutter_test/flutter_test.dart';

import 'package:dart_json/dart_json.dart';

void main() {
  test('intValue', () {
    final json = Json.fromString("1");
    assert(json.intValue == 1);

    json.intValue = 2;
    assert(json.intValue == 2);

    json.intValue = null;
    assert(json.intValue == null);

    assert(Json.fromString("null").intValue == null);
  });

  test('dynamicValue', () {
    final json = Json.fromString("1");
    assert(json.dynamicValue == 1);

    json.dynamicValue = 2;
    assert(json.dynamicValue == 2);

    json.dynamicValue = null;
    assert(json.dynamicValue == null);

    assert(Json.fromString("null").dynamicValue == null);
  });

  test('map set', () {
    final json = Json.object();
    json["intKey"].intValue = 1;
    json["strKey"].stringValue = "str";
    json["nullKey"].stringValue = null;
    assert(json["intKey"].intValue == 1);
    assert(json["strKey"].stringValue == "str");
    assert(json["nullKey"].intValue == null);
  });

  test('map get', () {
    final json = Json.fromString('{"intKey": 1, "strKey": "str", "nullKey": null}');
    assert(json["intKey"].intValue == 1);
    assert(json["strKey"].stringValue == "str");
    assert(json["nullKey"].intValue == null);
  });

  test('list get', () {
    final json = Json.fromString('[{"name": "John"},{"name": "Jack"}]');
    final list = json.list;
    assert(list.length == 2);
    assert(list[0]["name"].stringValue == "John");
    assert(list[1]["name"].stringValue == "Jack");
  });

  test('unformatted string conversion', () {
    final originalStr = '[{"name":"John"},{"name":"Jack"}]';
    final json = Json.fromString(originalStr);
    final restoredStr = json.toString();
    assert(originalStr == restoredStr);
  });

  test('json object to string', () {
    final json = Json.object();
    json["intKey"].intValue = 1;
    json["strKey"].stringValue = "str";
    json["nullKey"].stringValue = null;
    final restoredStr = json.toString();
    assert(restoredStr == '{"intKey":1,"strKey":"str","nullKey":null}');
  });

  test('json with nested object to string', () {
    final json = Json.object();
    json["nested"] = Json.object();
    json["nested"]["value"].stringValue = "str";
    json["nested"]["nested"] = Json.object();
    json["nested"]["nested"]["value"].stringValue = "str";

    final restoredStr = json.toString();
    assert(restoredStr == '{"nested":{"value":"str","nested":{"value":"str"}}}');
  });

}
