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
    final json = Json.fromString('{}');
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

}
