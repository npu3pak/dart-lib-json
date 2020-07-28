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
final str = """
{"title": "Roadside Picnic", "year": 1972, "inStock": false }
""";

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
json["bool"].boolValue = true;
```

The same using dynamic types:
```dart
Json json = Json.object();
json["int"].dynamicValue = 1;
json["string"].dynamicValue = "str";
json["double"].dynamicValue = 1.1;
json["bool"].dynamicValue = true;
```

### Reading values
```dart
final intVal = json["year"].intValue;
final stringVal = json["title"].stringValue;
final doubleVal = json["price"].doubleValue;
final boolVal = json["inStock"].boolValue;
```

With dynamic types:
```dart
final intVal = json["year"].dynamicValue;
final stringVal = json["title"].dynamicValue;
final doubleVal = json["price"].dynamicValue;
final boolVal = json["inStock"].dynamicValue;
```

### Checking if a value exists
You can check if the JSON contains the element with the giving name:
```dart
if (item["element"].dynamicValue != null) {

}
```
Example:

```dart
final json = Json([
  {"name": "John"},
  {
    "name": "Nick",
    "extra": {"phone": "123-4567"}
  }
]);

for (var item in json.list) {
  if (item["extra"].dynamicValue != null) {
    print(item["name"].stringValue);
  }
}
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

### Working with a JSON list
You can create a JSON list from a list of JSON objects:

```dart
final item1 = Json({"name": "John"});
final item2 = Json({"name": "Nick"});
final json = Json([item1, item2]);
```

You can create a JSON list from a list of dictionaries:

```dart
final json = Json([
    {"name": "John"},
    {"name": "Nick"},
]);
```

You can access a list of a JSON object with the **list** property.

```dart
List<Json> jsonList = json.list;
```

You can create an empty array and fill it with items using the **add()** method:

```dart
final item1 = Json({"item": 1});
final item2 = Json({"item": 2});
final json = Json.list(); // []
json.list.add(item1); // [{"item":1}]
json.list.add(item2); // [{"item":2}]
```

You can modify a list of items like this:

```dart
final item1 = Json({"item": 1});
final item2 = Json({"item": 2});
final json = Json([item1]); // [{"item":1}]
json.list.remove(item1); // []
json.list.add(item2); // [{"item":2}]
```

### Parsing a response string
```dart
final responseString = """
{
  "books": [
    {"title": "Hard to Be a God", "year": 1964, "inStock": true, "price": 5.99 },
    {"title": "Prisoners of Power", "year": 1971, "inStock": true, "price": 5.99 },
    {"title": "Roadside Picnic", "year": 1972, "inStock": false }
  ]
}
""";

class Book {
  final String title;
  final int year;
  final bool inStock;
  final double price;

  Book({this.title, this.year, this.inStock, this.price});
}

main() {
  Json json = Json.parse(responseString);

  List<Book> books = json["books"].list.map(
      (j) => Book(
        title: j["title"].stringValue,
        year: j["year"].intValue,
        inStock: j["inStock"].boolValue,
        price: j["price"].doubleValue,
      ),
    ).toList();
  }
```
### Making JSON from an objects list
```dart
final books = [
  Book(title: "Beetle in the Anthill", year: 1979, inStock: true, price: 5.99)
];

final listJson = Json.list();
for (final book in books) {
  var itemJson = Json.object();
  itemJson["title"].stringValue = book.title;
  itemJson["year"].intValue = book.year;
  itemJson["inStock"].boolValue = book.inStock;
  itemJson["price"].doubleValue = book.price;
  listJson.list.add(itemJson);
}

print(listJson.asPrettyString());
```

### Parsing custom types
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
