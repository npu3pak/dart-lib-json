import 'package:flutter_test/flutter_test.dart';

import 'package:dart_json/dart_json.dart';

void main() {
  group('init', () {
    test('init with a simple value', () {
      final nullJson = Json(null);
      expect(nullJson.intValue, null);

      final intJson = Json(1);
      expect(intJson.intValue, 1);

      final stringJson = Json("abc");
      expect(stringJson.stringValue, "abc");

      final doubleJson = Json(9.9);
      expect(doubleJson.doubleValue, 9.9);

      final boolJson = Json(true);
      expect(boolJson.boolValue, true);
    });

    test('init with dictionary', () {
      final j = Json({
        "null": null,
        "int": 1,
        "string": "abc",
        "double": 9.9,
        "bool": true,
        "inner1": {
          "key1":"value1",
          "inner2": {
            "key2":"value2"
          }
        },
        "list": [1,2]
      });

      expect(j["null"].intValue, null);
      expect(j["int"].intValue, 1);
      expect(j["string"].stringValue, "abc");
      expect(j["double"].doubleValue, 9.9);
      expect(j["bool"].boolValue, true);
      expect(j["inner1"]["key1"].stringValue, "value1");
      expect(j["inner1"]["inner2"]["key2"].stringValue, "value2");
      expect(j["list"].list[0].intValue, 1);
    });

    test('init with json', () {
      final source = Json({
        "null": null,
        "int": 1,
        "string": "abc",
        "double": 9.9,
        "bool": true,
        "inner1": {
          "key1":"value1",
          "inner2": {
            "key2":"value2"
          }
        },
        "list": [1,2]
      });
      final j = Json(source);

      expect(j["null"].intValue, null);
      expect(j["int"].intValue, 1);
      expect(j["string"].stringValue, "abc");
      expect(j["double"].doubleValue, 9.9);
      expect(j["bool"].boolValue, true);
      expect(j["inner1"]["key1"].stringValue, "value1");
      expect(j["inner1"]["inner2"]["key2"].stringValue, "value2");
      expect(j["list"].list[0].intValue, 1);
    });

    test('init with list of simple values', () {
      final j = Json([1,2]);

      expect(j.list[0].intValue, 1);
      expect(j.list[1].intValue, 2);
    });

    test('init with list of json objects', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final j = Json([item1,item2]);

      expect(j.list[0]["name"].stringValue, "John");
      expect(j.list[1]["name"].stringValue, "Jack");
    });
  });
  
  group('empty init', () {
    test('init with null', () {
      final j = Json.empty();

      expect(j.stringValue, null);
    });

    test('init empty object', () {
      final j = Json.object();
      j["key"].stringValue = "value";

      expect(j["key"].stringValue, "value");
    });

    test('init empty list', () {
      final j = Json.list();
      j.list.add(Json(1));

      expect(j.list[0].intValue, 1);
    });
  });

  group('serialization and deserialization', () {
    test('parse and asString', () {
      final str = """{
        "null": null,
        "int": 1,
        "string": "abc",
        "double": 9.9,
        "bool": true,
        "inner1": {
          "key1":"value1",
          "inner2": {
            "key2":"value2"
          }
        },
        "list": [1,2]
      }""";
      final j = Json.parse(str);

      expect(j["null"].intValue, null);
      expect(j["int"].intValue, 1);
      expect(j["string"].stringValue, "abc");
      expect(j["double"].doubleValue, 9.9);
      expect(j["bool"].boolValue, true);
      expect(j["inner1"]["key1"].stringValue, "value1");
      expect(j["inner1"]["inner2"]["key2"].stringValue, "value2");
      expect(j["list"].list[0].intValue, 1);

      final unformattedString = str.replaceAll(" ", "").replaceAll("\n", "");
      expect(j.asString(), unformattedString);
    });
  });
  
  group('intValue', () {
    test('.parse() value', () {
      final json = Json.parse("1");
  
      expect(json.intValue, equals(1));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.intValue, isNull);
    });

    test('assigned value', () {
      final json = Json.parse("1");
      json.intValue = 2;

      expect(json.intValue, equals(2));
    });

    test('assigned null', () {
      final json = Json.parse("1");
      json.intValue = null;

      expect(json.intValue, isNull);
    });
  });

  group('dynamicValue', () {
    test('.parse() value', () {
      final json = Json.parse("1");

      expect(json.dynamicValue, equals(1));
    });

    test('.parse() null', () {
      final json = Json.parse("null");

      expect(json.dynamicValue, isNull);
    });

    test('assigned value', () {
      final json = Json.parse("1");
      json.dynamicValue = 2;

      expect(json.dynamicValue, equals(2));
    });

    test('assigned null', () {
      final json = Json.parse("1");
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

    test('.parse', () {
      final json = Json.parse('{"intKey": 1, "strKey": "str", "nullKey": null}');

      expect(json["intKey"].intValue, equals(1));
      expect(json["strKey"].stringValue, equals("str"));
      expect(json["nullKey"].intValue, isNull);
    });
  });

  group('list', () {
    test('.parse', () {
      final json = Json.parse('[{"name": "John"},{"name": "Jack"}]');
      final list = json.list;

      expect(list.length, equals(2));
    });

    test('get elements', () {
      final json = Json.parse('[{"name": "John"},{"name": "Jack"}]');
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

    test('asString', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final json = Json.object();
      json["list"].list = [item1, item2];

      expect(json.asString(), '{"list":[{"name":"John"},{"name":"Jack"}]}');
    });

    test('list constructor', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final json = Json([item1, item2]);

      expect(json.list[0]["name"].stringValue, "John");
      expect(json.list[1]["name"].stringValue, "Jack");
      expect(json.asString(), '[{"name":"John"},{"name":"Jack"}]');
    });
  });

  test('unformatted string conversion', () {
    final originalStr = '[{"name":"John"},{"name":"Jack"}]';
    final json = Json.parse(originalStr);
    final restoredStr = json.asString();

    expect(originalStr, equals(restoredStr));
  });

  test('json object to string', () {
    final json = Json.object();
    json["intKey"].intValue = 1;
    json["strKey"].stringValue = "str";
    json["nullKey"].stringValue = null;
    final restoredStr = json.asString();

    expect(restoredStr, equals('{"intKey":1,"strKey":"str","nullKey":null}'));
  });


  group('asString', () {
    test('json with nested object', () {
      final json = Json.object();
      json["value"].stringValue = "str";
      json["nested"]["value"].stringValue = "str";
      json["nested"]["nested"]["value"].stringValue = "str";
      final restoredStr = json.asString();

      expect(restoredStr, equals('{"value":"str","nested":{"value":"str","nested":{"value":"str"}}}'));
    });

    test('simple value', () {
      final json = Json(1);
      expect(json.intValue, equals(1));
      final restoredStr = json.asString();
      expect(restoredStr, equals('1'));
    });
  });

}
