import 'package:flutter_test/flutter_test.dart';

import 'package:dart_json/dart_json.dart';

void main() {
  group('intValue', () {
    test('.fromString() value', () {
      final json = Json.fromString("1");
  
      expect(json.intValue, equals(1));
    });

    test('.fromString null', () {
      final json = Json.fromString("null");

      expect(json.intValue, isNull);
    });

    test('assigned value', () {
      final json = Json.fromString("1");
      json.intValue = 2;

      expect(json.intValue, equals(2));
    });

    test('assigned null', () {
      final json = Json.fromString("1");
      json.intValue = null;

      expect(json.intValue, isNull);
    });
  });

  group('dynamicValue', () {
    test('.fromString() value', () {
      final json = Json.fromString("1");

      expect(json.dynamicValue, equals(1));
    });

    test('.fromString() null', () {
      final json = Json.fromString("null");

      expect(json.dynamicValue, isNull);
    });

    test('assigned value', () {
      final json = Json.fromString("1");
      json.dynamicValue = 2;

      expect(json.dynamicValue, equals(2));
    });

    test('assigned null', () {
      final json = Json.fromString("1");
      json.dynamicValue = null;

      expect(json.dynamicValue, isNull);
    });
  });

  group('map', () {
    test('set values', () {
      final json = Json.object();
      json["intKey"].intValue = 1;
      json["strKey"].stringValue = "str";
      json["nullKey"].stringValue = null;

      expect(json["intKey"].intValue, equals(1));
      expect(json["strKey"].stringValue, equals("str"));
      expect(json["nullKey"].intValue, isNull);
    });

    test('.fromString', () {
      final json = Json.fromString('{"intKey": 1, "strKey": "str", "nullKey": null}');

      expect(json["intKey"].intValue, equals(1));
      expect(json["strKey"].stringValue, equals("str"));
      expect(json["nullKey"].intValue, isNull);
    });
  });

  group('list', () {
    test('.fromString', () {
      final json = Json.fromString('[{"name": "John"},{"name": "Jack"}]');
      final list = json.list;

      expect(list.length, equals(2));
    });

    test('get elements', () {
      final json = Json.fromString('[{"name": "John"},{"name": "Jack"}]');
      final list = json.list;

      expect(list[0]["name"].stringValue, equals("John"));
      expect(list[1]["name"].stringValue, equals("Jack"));
    });

    test('set list', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final json = Json.object();
      json["list"].list = [item1, item2];

      expect(json["list"].list[0]["name"].stringValue, "John");
      expect(json["list"].list[1]["name"].stringValue, "Jack");
    });

    test('list append', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final item3 = Json({"name":"Stan"});
      final json = Json.object();
      json["list"].list = [item1, item2];
      var list = json["list"].list;
      json["list"].list.add(item3);
      list.add(item3);

      expect(json["list"].list[0]["name"].stringValue, "John");
      expect(json["list"].list[1]["name"].stringValue, "Jack");
      expect(json["list"].list[2]["name"].stringValue, "Stan");
    });

    test('toString', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final json = Json.object();
      json["list"].list = [item1, item2];

      expect(json.toString(), '{"list":[{"name":"John"},{"name":"Jack"}]}');
    });

    test('list constructor', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final json = Json.list([item1, item2]);

      expect(json.list[0]["name"].stringValue, "John");
      expect(json.list[1]["name"].stringValue, "Jack");
      expect(json.toString(), '[{"name":"John"},{"name":"Jack"}]');
    });
  });

  test('unformatted string conversion', () {
    final originalStr = '[{"name":"John"},{"name":"Jack"}]';
    final json = Json.fromString(originalStr);
    final restoredStr = json.toString();

    expect(originalStr, equals(restoredStr));
  });

  test('json object to string', () {
    final json = Json.object();
    json["intKey"].intValue = 1;
    json["strKey"].stringValue = "str";
    json["nullKey"].stringValue = null;
    final restoredStr = json.toString();

    expect(restoredStr, equals('{"intKey":1,"strKey":"str","nullKey":null}'));
  });


  group('toString', () {
    test('json with nested object', () {
      final json = Json.object();
      json["value"].stringValue = "str";
      json["nested"]["value"].stringValue = "str";
      json["nested"]["nested"]["value"].stringValue = "str";
      final restoredStr = json.toString();

      expect(restoredStr, equals('{"value":"str","nested":{"value":"str","nested":{"value":"str"}}}'));
    });

    test('simple value', () {
      final json = Json(1);
      expect(json.intValue, equals(1));
      final restoredStr = json.toString();
      expect(restoredStr, equals('1'));
    });
  });

}
