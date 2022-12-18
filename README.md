# Dart JSON

A library intended to bring manual JSON serialization to the Dart projects of all scales.

Features:
- Human readable and maintainable API
- Strict compile-time and runtime types checks
- Nested objects parsing
- Lists of objects parsing
- Exceptions that include a JSON key path with an error
- Sound null safety support

## Installing
Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  dart_json: ^2.0.1
```

Install dependencies:
```
pub get
```

Import the library:
```dart
import 'package:dart_json/dart_json.dart';
```

## Basic usage

### String parsing
```dart
final str = '{"title": "Roadside Picnic", "year": 1972, "inStock": false}';
try {
  final json = Json.parse(str);
} on JsonException catch (e) {
  print(e)
}
```

### Converting JSON to string
```dart
final unformatted = json.asString();
final formatted = json.asPrettyString();
```

### Making an empty JSON
```dart
Json nullJson = Json.empty(); // null
Json emptyList = Json.list(); // []
Json emptyObject = Json.object(); // {}
```

### Making JSON from a value
```dart
Json intJson = Json(1); // 1
Json doubleJson = Json(1.1); // 1.1
Json stringJson = Json("str"); // "str"
Json boolJson = Json(true); // true
```

### Writing values
```dart
Json json = Json.object();
json["int"].intValue = 1;
json["string"].stringValue = "str";
json["double"].doubleValue = 1.1;
json["double"].numValue = 1.1;
json["bool"].boolValue = true;
```

### Reading values
The nullable values can be read like this:
```dart
try {
  int? intVal = json["year"].intValue;
  String? stringVal = json["title"].stringValue;
  double? doubleVal = json["price"].doubleValue;
  num? numValue = json["price"].numValue;
  bool? boolVal = json["inStock"].boolValue;
} on JsonValueException catch (e) {
  print(e.value) // The value of the faulty field
  print(e) // "Unable to parse the value at the/path/to/field"...
}
```
In this case, the JsonValueException will be thrown if the type of the value is incorrect. The null value is permitted.

### Required values
If the value must not be null, you can use the \*OrException properties:
```dart
try {
  int intVal = json["year"].intOrException;
  String stringVal = json["title"].stringOrException;
  double doubleVal = json["price"].doubleOrException;
  num numValue = json["price"].numOrException;
  bool boolVal = json["inStock"].boolOrException;
} on JsonValueException catch (e) {
  print(e.value) // The value of the faulty field
  print(e) // "Unable to parse the required value at the/path/to/field"...
}
```
In this case, the JsonValueException will be thrown if the type of the value is incorrect or the value is null.

### Making JSON objects
From a dictionary:
```dart
final json = Json({
    "name": "John",
    "age": 20,
    "contacts": {
      "email": "john@doe.com",
      "phones": ["754-3010"]
    }
  });
```

Manually:
```dart
final json = Json.object();
json["name"].stringValue = "John";
json["age"].intValue = 20;
json["contacts"] = Json.object();
json["contacts"]["email"].stringValue = "john@doe.com";
json["contacts"]["phones"] = Json.list();
json["contacts"]["phones"].list.add(Json("754-3010"));
```

### Accessing values of a nested object
```dart
final value = j["root"]["nested"].stringValue;
```

In the example above the keys "root" and "nested" **must not be null**, otherwise the JsonException will be thrown.
If you need to parse the nested JSON with keys that can be null, you should check it explicitly.

```dart
final value1 = j["inexisted"]["nested"].stringValue; // JsonException

final value2 = j["inexisted"].isExist 
  ? j["inexisted"]["nested"].stringValue 
  : null; // null
```

You can also use the shortcut.
```dart
final value = j["inexisted"].optional["nested"].stringValue; // null
```

In the example, we marked the path "inexisted" as **optional**. The JSON parser will know that the "inexisted" can be null. And the "nested" and all the keys to the right side of "inexisted" can be null as well.

### Null checks
You can check if the JSON value is **not null**:
```dart
final json = Json.empty(); // json with null
print(json != null) // true
print(json.isExist) // false
```

You can check if the JSON object contains the element with the giving name:
```dart
final json = Json.object(); // json with {}
print(json.isExist) // true
print(json["key"].isExist) // false
```

### Type checks
You can check the runtime type of the JSON value:
```dart
Json("value").isA<String>; // true
Json("value").isNot<int>; // true
```

You can also check the type of the "dynamicValue" property:
```dart
Json("value").dynamicValue is String; // true
Json("value").dynamicValue is int; // false
```

### Working with a JSON list
You can create a JSON list:

```dart
final fromAListOfValues = Json(["John", "Jack"]);
final fromAListOfDictionaries = Json([{"name": "John"}, {"name": "Nick"}]);
final fromAListOfJsons = Json([Json("John"), Json("Jack")]);
```

You can access a list of a JSON object with the **list** property.

```dart
List<Json> jsonList = json.list;
```

You can create an empty array and fill it with items using the **add()** method:

```dart
final json = Json.list(); // []
json.list.add(Json({"item": 1})); // [{"item":1}]
json.list.add(Json({"item": 2})); // [{"item":1}, {"item":2}]
```

You can modify a list of items like this:

```dart
final item1 = Json({"item": 1});
final item2 = Json({"item": 2});

final json = Json([item1]); // [{"item":1}]
json.list.remove(item1); // []
json.list.add(item2); // [{"item":2}]
```

### Working with an objects list
```dart

class Book {
  final String title;
  final int year;
  final bool inStock;
  final double price;

  Book({this.title, this.year, this.inStock, this.price});
}

final books = [
  Book(title: "Beetle in the Anthill", year: 1979, inStock: true, price: 5.99)
];

// Making the JSON from the object list
Json listJson = Json.fromObjectList(books, (Book item) {
  var j = Json.object();
  j["title"].stringValue = item.title;
  j["year"].intValue = item.year;
  j["inStock"].boolValue = item.inStock;
  j["price"].doubleValue = item.price;
  return j;
});

// Making the object list from the JSON
List<Book>? objectList = listJson.toObjectList(
  (j) => Book(
    title: j["title"].stringValue!,
    year: j["year"].intValue!,
    inStock: j["inStock"].boolValue!,
    price: j["price"].doubleValue!,
  ),
);
```

### Working with custom types
Sometimes you need to work with enums, dates, and other custom types in JSON.
```dart
enum Status { active, old }
```

You can implement a JsonAdapter to parse values of a custom type.

```dart
class StatusAdapter implements JsonAdapter<Status> {
  @override
  Status? fromJson(Json json) {
    switch (json.stringValue) {
      case "active":
        return Status.active;
      case "old":
        return Status.old;
      default:
        return null;
    }
  }

  @override
  Json toJson(Status? value) {
    if (value == null) {
      return Json.empty();
    }
    switch (value) {
      case Status.active:
        return Json("active");
      case Status.old:
        return Json("old");
      default:
        return Json.empty();
    }
  }
}
```

Now you can work with JSON values of the custom type using the **get** and **set** methods.
```dart
final valueJson = Json.empty();
valueJson.set(Status.active, StatusAdapter());
Status? valueStatus = valueJson.get(StatusAdapter());

final objectJson = Json.object();
objectJson["key"].set(Status.active, StatusAdapter());
Status? ojectStatus = objectJson["key"].get(StatusAdapter());
```

If the value must not be null, you can use the **getRequired** method.
```dart
final valueJson = Json.empty();
valueJson.set(Status.active, StatusAdapter());
Status valueStatus = valueJson.getRequired(StatusAdapter());

```
If the custom adapter returns null, the **getRequired** method will throw a JsonValueException.
```dart
try {
  Json("incorrect").getRequired(StatusAdapter());
} on JsonValueException catch (e) {
  print(e.value) // The value of the faulty field
  print(e) // "Unable to parse the required value at the/path/to/field"...
}
```

## Authors

Evgeniy Safronov (evsafronov.personal@gmail.com)

Alexander Smetannikov (alexsmetdev@gmail.com)

## License

Dart JSON is available under the MIT license. See the LICENSE file for more info.
