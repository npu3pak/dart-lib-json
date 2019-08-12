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

    test('asPrettyString', () {
      final str = """{
  "null": null,
  "int": 1,
  "string": "abc",
  "double": 9.9,
  "bool": true,
  "inner1": {
    "key1": "value1",
    "inner2": {
      "key2": "value2"
    }
  },
  "list": [
    1,
    2
  ]
}""";
      final j = Json.parse(str);
      expect(j.asPrettyString(), equals(str));
    });
  });

  group('set and get object values', () {
    test('set object values', () {
      final j = Json.object();
      j["k"].stringValue = "v";
      j["list"] = Json([1,2]);
      j["nested"]["nestedList"] = Json([Json(1),Json(2)]);

      expect(j.asString(), '{"k":"v","list":[1,2],"nested":{"nestedList":[1,2]}}');
    });

    test('get object values', () {
      final j = Json.parse('{"k":"v","list":[1,2],"nested":{"nestedList":[1,2]}}');

      expect(j["k"].stringValue, "v");
      expect(j["list"].list[0].intValue, 1);
      expect(j["nested"]["nestedList"].list[0].intValue, 1);
    });
  });

  group('working with arrays', () {
    test('working with arrays', () {
      final str = '[1,2,3]';
      final j = Json.parse(str);
      expect(j.list[0].intValue, 1);

      j.list.add(Json(4));
      expect(j.list[3].intValue, 4);

      j.list[3] = Json(5);
      expect(j.list[3].intValue, 5);
    });
  });

  group('numValue', () {
    test('.parse() value', () {
      final json = Json.parse("1");

      expect(json.numValue, equals(1));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.numValue, isNull);
    });

    test('assigned int value', () {
      final json = Json.parse("1");
      json.numValue = 2;

      expect(json.numValue, equals(2));
    });

    test('assigned double value', () {
      final json = Json.parse("1.1");
      json.numValue = 2.2;

      expect(json.numValue, equals(2.2));
    });

    test('assigned null', () {
      final json = Json.parse("1");
      json.numValue = null;

      expect(json.numValue, isNull);
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

  group('doubleValue', () {
    test('.parse() value', () {
      final json = Json.parse("1.0");

      expect(json.doubleValue, equals(1.0));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.doubleValue, isNull);
    });

    test('assigned double value', () {
      final json = Json.parse("1.0");
      json.doubleValue = 2.0;

      expect(json.doubleValue, equals(2.0));
    });

    test('assigned int value', () {
      final json = Json.parse("1.0");
      json.doubleValue = 2;

      expect(json.doubleValue, equals(2.0));
    });

    test('assigned null', () {
      final json = Json.parse("1");
      json.doubleValue = null;

      expect(json.doubleValue, isNull);
    });
  });

  group('stringValue', () {
    test('.parse() value', () {
      final json = Json.parse('"Str"');

      expect(json.stringValue, 'Str');
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.stringValue, isNull);
    });

    test('.assigned value', () {
      final json = Json.object();
      json["strKey"].stringValue = 'Str';

      expect(json["strKey"].stringValue, 'Str');
    });

    test('.assigned null', () {
      final json = Json.object();
      json["strKey"].stringValue = null;

      expect(json["strKey"].stringValue, isNull);
    });
  });

  group('boolValue', () {
    test('.parse() value', () {
      final json = Json.parse("true");

      expect(json.boolValue, equals(true));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.boolValue, isNull);
    });

    test('.assigned value', () {
      final json = Json.object();
      json["boolTrueKey"].boolValue = true;
      json["boolFalseKey"].boolValue = false;

      expect(json["boolTrueKey"].boolValue, equals(true));
      expect(json["boolFalseKey"].boolValue, equals(false));
    });

    test('.assigned null', () {
      final json = Json.object();
      json["boolKey"].boolValue = null;

      expect(json["boolKey"].boolValue, isNull);
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
      json["list"] = Json([item1, item2]);

      expect(json["list"].list[0]["name"].stringValue, "John");
      expect(json["list"].list[1]["name"].stringValue, "Jack");
    });

    test('list append', () {
      final item1 = Json({"name":"John"});
      final item2 = Json({"name":"Jack"});
      final item3 = Json({"name":"Stan"});
      final json = Json.object();
      json["list"] = Json([item1, item2]);
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
      json["list"] = Json([item1, item2]);

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
    json["dynamicKey"].dynamicValue = "dynamic";
    json["numKey"].numValue = 1.1;
    json["intKey"].intValue = 1;
    json["doubleKey"].doubleValue = 2.2;
    json["strKey"].stringValue = "str";
    json["boolKey"].boolValue = true;
    json["nullKey"].stringValue = null;
    final restoredStr = json.asString();

    expect(restoredStr, equals('{"dynamicKey":"dynamic","numKey":1.1,"intKey":1,"doubleKey":2.2,"strKey":"str","boolKey":true,"nullKey":null}'));
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

  group('custom types', () {
    test('custom types', () {
      final j = Json.object();
      j["gender"].stringValue = "M";
      expect(j["gender"].get(GenderAdapter()), Gender.male);

      j["gender"].set(Gender.female, GenderAdapter());
      expect(j["gender"].stringValue, "F");

      j["gender"].stringValue = "Unknown";
      expect(j["gender"].get(GenderAdapter()), null);
    });
  });
}

enum Gender {
  male, female
}

class GenderAdapter implements JsonAdapter<Gender> {
  @override
  Gender fromJson(Json json) {
    switch (json.stringValue ?? "") {
      case "M": return Gender.male;
      case "F": return Gender.female;
      default: return null;
    }
  }

  @override
  Json toJson(Gender value) {
    switch (value) {
      case Gender.male: return Json("M");
      case Gender.female: return Json("F");
      default: return Json.empty();
    }
  }
}

