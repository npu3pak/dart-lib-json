import 'package:flutter_test/flutter_test.dart';
import 'package:dart_json/dart_json.dart';

void main() {
  group('init', () {
    test('init with a simple value', () {
      final nullJson = Json(null);
      expect(nullJson.intValue, null);

      final numJson = Json(1);
      expect(numJson.intValue, 1);

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
          "key1": "value1",
          "inner2": {"key2": "value2"}
        },
        "list": [1, 2]
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
          "key1": "value1",
          "inner2": {"key2": "value2"}
        },
        "list": [1, 2]
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
      final j = Json([1, 2]);

      expect(j.list[0].intValue, 1);
      expect(j.list[1].intValue, 2);
    });

    test('init with list of json objects', () {
      final item1 = Json({"name": "John"});
      final item2 = Json({"name": "Jack"});
      final j = Json([item1, item2]);

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

  group("null checks", () {
    test('init with null', () {
      final j = Json.empty();

      expect(j.isExist, false);
    });

    test('init empty object', () {
      final j = Json.object();

      expect(j.isExist, true);
      expect(j["key"].isExist, false);

      j["key"].stringValue = "value";
      expect(j["key"].isExist, true);
    });
  });

  group("type checks", () {
    test('init with null', () {
      final j = Json.empty();

      expect(j.isOf<String>(), false);
      expect(j.isNotOf<String>(), true);
      expect(j.dynamicValue is String, false);
    });

    test('init with object', () {
      final j1 = Json.object();
      final j2 = Json({"1": 1});

      expect(j1.isOf<Map>(), true);
      expect(j1.isNotOf<Map>(), false);
      expect(j1.dynamicValue is Map, true);

      expect(j2.isOf<Map>(), true);
      expect(j2.isNotOf<Map>(), false);

      expect(j2.isOf<Map<String, dynamic>>(), true);
      expect(j2.isNotOf<Map<String, int>>(), true);
    });

    test('init with list', () {
      final j = Json.list();

      expect(j.isOf<List>(), true);
      expect(j.isNotOf<List>(), false);
      expect(j.dynamicValue is List, true);

      expect(j.isOf<List<dynamic>>(), true);
    });

    test('init with String', () {
      final j = Json("value");
      expect(j.isOf<String>(), true);
      expect(j.isOf<int>(), false);
      expect(j.isOf<double>(), false);
      expect(j.isOf<num>(), false);
      expect(j.isOf<bool>(), false);

      expect(j.isNotOf<String>(), false);
      expect(j.isNotOf<int>(), true);
      expect(j.isNotOf<double>(), true);
      expect(j.isNotOf<num>(), true);
      expect(j.isNotOf<bool>(), true);

      expect(j.dynamicValue is String, true);
    });

    test('init with Number', () {
      final j = Json(123);
      expect(j.isOf<String>(), false);
      expect(j.isOf<int>(), true);
      expect(j.isOf<double>(), false);
      expect(j.isOf<num>(), true);
      expect(j.isOf<bool>(), false);

      expect(j.isNotOf<String>(), true);
      expect(j.isNotOf<int>(), false);
      expect(j.isNotOf<double>(), true);
      expect(j.isNotOf<num>(), false);
      expect(j.isNotOf<bool>(), true);

      expect(j.dynamicValue is int, true);
      expect(j.dynamicValue is num, true);
    });
  });

  group('key path', () {
    test('key path', () {
      final j = Json({
        "null": null,
        "inner1": {
          "key1": "value1",
          "inner2": {"key2": "value2"}
        },
        "list": [1, 2]
      });

      expect(j.keyPath, "/");
      expect(j["null"].keyPath, "/null");
      expect(j["inner1"].keyPath, "/inner1");
      expect(j["inner1"]["key1"].keyPath, "/inner1/key1");
      expect(j["list"].keyPath, "/list");
      expect(j["list"].list[0].keyPath, "/list/0");
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
      j["list"] = Json([1, 2]);
      j["nested"] = Json.object();
      j["nested"]["nestedList"] = Json([Json(1), Json(2)]);

      expect(
          j.asString(), '{"k":"v","list":[1,2],"nested":{"nestedList":[1,2]}}');
    });

    test('get object values', () {
      final j =
          Json.parse('{"k":"v","list":[1,2],"nested":{"nestedList":[1,2]}}');

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
      expect(json.numOrException, equals(1));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.numValue, isNull);
      expect(
        () => json.numOrException,
        throwsA(isA<JsonValueException>()),
      );
    });

    test('assigned int value', () {
      final json = Json.parse("1");
      json.numValue = 2;

      expect(json.numValue, equals(2));
      expect(json.numOrException, equals(2));
    });

    test('assigned double value', () {
      final json = Json.parse("1.1");
      json.numValue = 2.2;

      expect(json.numValue, equals(2.2));
      expect(json.numOrException, equals(2.2));
    });

    test('assigned null', () {
      final json = Json.parse("1");
      json.numValue = null;

      expect(json.numValue, isNull);
      expect(
        () => json.numOrException,
        throwsA(isA<JsonValueException>()),
      );
    });
  });

  group('intValue', () {
    test('.parse() value', () {
      final json = Json.parse("1");

      expect(json.intValue, equals(1));
      expect(json.intOrException, equals(1));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.intValue, isNull);
      expect(
        () => json.intOrException,
        throwsA(isA<JsonValueException>()),
      );
    });

    test('assigned value', () {
      final json = Json.parse("1");
      json.intValue = 2;

      expect(json.intValue, equals(2));
      expect(json.intOrException, equals(2));
    });

    test('assigned null', () {
      final json = Json.parse("1");
      json.intValue = null;

      expect(json.intValue, isNull);
      expect(
        () => json.intOrException,
        throwsA(isA<JsonValueException>()),
      );
    });
  });

  group('doubleValue', () {
    test('.parse() value', () {
      final json = Json.parse("1.0");

      expect(json.doubleValue, equals(1.0));
      expect(json.doubleOrException, equals(1.0));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.doubleValue, isNull);
      expect(
        () => json.doubleOrException,
        throwsA(isA<JsonValueException>()),
      );
    });

    test('assigned double value', () {
      final json = Json.parse("1.0");
      json.doubleValue = 2.0;

      expect(json.doubleValue, equals(2.0));
      expect(json.doubleOrException, equals(2.0));
    });

    test('assigned int value', () {
      final json = Json.parse("1.0");
      json.doubleValue = 2;

      expect(json.doubleValue, equals(2.0));
      expect(json.doubleOrException, equals(2.0));
    });

    test('assigned null', () {
      final json = Json.parse("1");
      json.doubleValue = null;

      expect(json.doubleValue, isNull);
      expect(
        () => json.intOrException,
        throwsA(isA<JsonValueException>()),
      );
    });
  });

  group('stringValue', () {
    test('.parse() value', () {
      final json = Json.parse('"Str"');

      expect(json.stringValue, 'Str');
      expect(json.stringOrException, equals('Str'));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.stringValue, isNull);
      expect(
        () => json.stringOrException,
        throwsA(isA<JsonValueException>()),
      );
    });

    test('.assigned value', () {
      final json = Json.object();
      json["strKey"].stringValue = 'Str';

      expect(json["strKey"].stringValue, 'Str');
      expect(json["strKey"].stringOrException, equals('Str'));
    });

    test('.assigned null', () {
      final json = Json.object();
      json["strKey"].stringValue = null;

      expect(json["strKey"].stringValue, isNull);
      expect(
        () => json["strKey"].stringOrException,
        throwsA(isA<JsonValueException>()),
      );
    });
  });

  group('boolValue', () {
    test('.parse() value', () {
      final json = Json.parse("true");

      expect(json.boolValue, equals(true));
      expect(json.boolOrException, equals(true));
    });

    test('.parse null', () {
      final json = Json.parse("null");

      expect(json.boolValue, isNull);
      expect(
        () => json.boolOrException,
        throwsA(isA<JsonValueException>()),
      );
    });

    test('.assigned value', () {
      final json = Json.object();
      json["boolTrueKey"].boolValue = true;
      json["boolFalseKey"].boolValue = false;

      expect(json["boolTrueKey"].boolValue, equals(true));
      expect(json["boolFalseKey"].boolValue, equals(false));
      expect(json["boolTrueKey"].boolOrException, equals(true));
      expect(json["boolFalseKey"].boolOrException, equals(false));
    });

    test('.assigned null', () {
      final json = Json.object();
      json["boolKey"].boolValue = null;

      expect(json["boolKey"].boolValue, isNull);
      expect(
        () => json["boolKey"].boolOrException,
        throwsA(isA<JsonValueException>()),
      );
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
      final json =
          Json.parse('{"intKey": 1, "strKey": "str", "nullKey": null}');

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

    test('set simple list', () {
      final json = Json([Json("John"), Json("Jack")]);

      expect(json.list[0].stringValue, "John");
      expect(json.list[1].stringValue, "Jack");
    });

    test('set simple values list', () {
      final json = Json(["John", "Jack"]);

      expect(json.list[0].stringValue, "John");
      expect(json.list[1].stringValue, "Jack");
    });

    test('set object list', () {
      final item1 = Json({"name": "John"});
      final item2 = Json({"name": "Jack"});
      final json = Json.object();
      json["list"] = Json([item1, item2]);

      expect(json["list"].list[0]["name"].stringValue, "John");
      expect(json["list"].list[1]["name"].stringValue, "Jack");
    });

    test('list append', () {
      final item1 = Json({"name": "John"});
      final item2 = Json({"name": "Jack"});
      final item3 = Json({"name": "Stan"});
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
      final item1 = Json({"name": "John"});
      final item2 = Json({"name": "Jack"});
      final json = Json.object();
      json["list"] = Json([item1, item2]);

      expect(json.asString(), '{"list":[{"name":"John"},{"name":"Jack"}]}');
    });

    test('list constructor', () {
      final item1 = Json({"name": "John"});
      final item2 = Json({"name": "Jack"});
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
    json["numKey"].numValue = 1.1;
    json["intKey"].intValue = 1;
    json["doubleKey"].doubleValue = 2.2;
    json["strKey"].stringValue = "str";
    json["boolKey"].boolValue = true;
    json["nullKey"].stringValue = null;
    final restoredStr = json.asString();

    expect(
      restoredStr,
      equals(
        '{"numKey":1.1,"intKey":1,"doubleKey":2.2,"strKey":"str","boolKey":true,"nullKey":null}',
      ),
    );
  });

  group('asString', () {
    test('json with nested object', () {
      final json = Json.object();
      json["value"].stringValue = "str";
      json["nested"] = Json.object();
      json["nested"]["value"].stringValue = "str";
      json["nested"]["nested"] = Json.object();
      json["nested"]["nested"]["value"].stringValue = "str";
      final restoredStr = json.asString();

      expect(
        restoredStr,
        equals(
          '{"value":"str","nested":{"value":"str","nested":{"value":"str"}}}',
        ),
      );
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

  group('list of objects', () {
    test("from json", () {
      final responseString = """{
        "books": [
          {"title": "Hard to Be a God", "year": 1964, "inStock": true, "price": 5.99 },
          {"title": "Prisoners of Power", "year": 1971, "inStock": true, "price": 5.99 },
          {"title": "Roadside Picnic", "year": 1972, "inStock": false }
        ]
      }
      """;

      Json json = Json.parse(responseString);
      List<Book>? books = json["books"].toObjectList<Book>(
        (Json j) => Book(
          title: j["title"].stringValue!,
          year: j["year"].intValue!,
          inStock: j["inStock"].boolValue!,
          price: j["price"].doubleValue,
        ),
      );

      expect(books?.length, 3);
      expect(books?.first.title, "Hard to Be a God");
      expect(books?.first.year, 1964);
      expect(books?.first.inStock, true);
      expect(books?.first.price, 5.99);
    });
  });

  test("to json", () {
    final books = [
      Book(
        title: "Beetle in the Anthill",
        year: 1979,
        inStock: true,
        price: 5.99,
      )
    ];

    Json json = Json.fromObjectList<Book>(books, (item) {
      var j = Json.object();
      j["title"].stringValue = item.title;
      j["year"].intValue = item.year;
      j["inStock"].boolValue = item.inStock;
      j["price"].doubleValue = item.price;
      return j;
    });

    final jsonStr = json.asString();

    expect(
      jsonStr,
      '[{"title":"Beetle in the Anthill","year":1979,"inStock":true,"price":5.99}]',
    );
  });

  group('optional', () {
    final j = Json({
      "null": null,
      "inner1": {
        "key1": "value1",
        "inner2": {"key2": "value2"}
      },
      "list": [1, 2]
    });

    test("get elements", () {
      final optional = j.optional;
      // Existed keys
      expect(j["inner1"]["key1"].stringValue, "value1");
      expect(optional["inner1"]["key1"].stringValue, "value1");

      // Inexisted keys in existed dictionary
      expect(j["inner1"]["key2"].stringValue, null);
      expect(optional["inner1"]["key2"].stringValue, null);

      // Inexisted dictionary
      expect(optional["inexisted"].stringValue, null);

      // Inexisted keys in inexisted dictionary
      expect(optional["inexisted"]["inexisted"].stringValue, null);
      expect(optional["inexisted"]["inexisted"]["inexisted"].stringValue, null);

      // Inexisted dictionary in existed dictionary
      expect(j["inner1"].optional["inexisted"].stringValue, null);
      expect(j["inner1"].optional["inexisted"]["inexisted"].stringValue, null);
    });

    test("setter", () {
      expect(j.isOptional, false);

      final optional = j.optional;
      expect(optional.isOptional, true);
    });

    test("inheritance", () {
      final optional = j.optional;
      expect(optional["null"].isOptional, true);
      expect(optional["inner1"].isOptional, true);
      expect(optional["inner1"]["key1"].isOptional, true);
      expect(optional["inner1"]["inner2"]["key2"].isOptional, true);
      expect(optional["list"].isOptional, true);

      // Items of JSON lists don't inherit the optional flag
      expect(optional["list"].list[0].isOptional, false);
      expect(optional["list"].list[0].optional.isOptional, true);
    });

    test("get elements", () {
      final optional = j.optional;
      // Existed keys
      expect(j["inner1"]["key1"].stringValue, "value1");
      expect(optional["inner1"]["key1"].stringValue, "value1");

      // Inexisted keys in existed dictionary
      expect(j["inner1"]["key2"].stringValue, null);
      expect(optional["inner1"]["key2"].stringValue, null);

      // Inexisted dictionary
      expect(optional["inexisted"].stringValue, null);

      // Inexisted keys in inexisted dictionary
      expect(optional["inexisted"]["inexisted"].stringValue, null);
      expect(optional["inexisted"]["inexisted"]["inexisted"].stringValue, null);

      // Inexisted dictionary in existed dictionary
      expect(j["inner1"].optional["inexisted"].stringValue, null);
      expect(j["inner1"].optional["inexisted"]["inexisted"].stringValue, null);
    });
  });
}

enum Gender { male, female }

class GenderAdapter implements JsonAdapter<Gender> {
  @override
  Gender? fromJson(Json json) {
    switch (json.stringValue ?? "") {
      case "M":
        return Gender.male;
      case "F":
        return Gender.female;
      default:
        return null;
    }
  }

  @override
  Json toJson(Gender? value) {
    switch (value) {
      case Gender.male:
        return Json("M");
      case Gender.female:
        return Json("F");
      default:
        return Json.empty();
    }
  }
}

class Book {
  final String title;
  final int year;
  final bool inStock;
  final double? price;

  Book({
    required this.title,
    required this.year,
    required this.inStock,
    required this.price,
  });
}
