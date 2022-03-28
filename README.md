# dart_json

JSON wrapper

## Installing
Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  dart_json:
      git:
        url: git://github.com/npu3pak/dart-lib-json.git
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
final json = Json.parse(str);
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
```dart
int? intVal = json["year"].intValue;
String? stringVal = json["title"].stringValue;
double? doubleVal = json["price"].doubleValue;
num? numValue = json["price"].numValue;
bool? boolVal = json["inStock"].boolValue;
```

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

### Accessing values from a nested object
```dart
final value1 = j["inner1"]["key1"].stringValue;
final value2 = j["inner1"]["inner2"]["key2"].stringValue;
```

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

### Working with a JSON list
You can create a JSON list:

```dart
final fromAListOfValues = Json(["John", "Jack"]);
final fromAListOfDictionaries = Json({"name": "John"}, {"name": "Nick"}]);
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
You must implement a JsonAdapter to parse values of a custom type.

```dart
final jsonStr = """
{
  "name": "John",
  "status": "active"
}
""";

class User {
  final String name;
  final Status status;

  User({this.name, this.status});
}

enum Status { active, old }

class StatusAdapter implements JsonAdapter<Status> {
  @override
  Status fromJson(Json json) {
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
  Json toJson(Status value) {
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

main() {
  final json = Json.parse(jsonStr);
  final user = User(
    name: json["name"].stringValue,
    status: json["status"].get(StatusAdapter())
  );
}
```

## Authors

Evgeniy Safronov (evsafronov.personal@yandex.ru)

Alexander Smetannikov (alexsmetdev@gmail.com)

## License

dart_json is available under the MIT license. See the LICENSE file for more info.
