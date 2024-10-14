import 'package:xml_converter/xml_converter.dart';

void main() async {
  final xmlString = '''
  <user>
    <name>ahmed talal</name>
    <age>26</age>
  </user>
  ''';

  final converter = XmlConverterBase();

  // Convert XML string to JSON file
  await converter.convertXmlToJsonFile(xmlString, 'user_data');

  // Convert XML string to Dart class file
  await converter.convertXmlToDartClass(xmlString, 'User', 'user_class');

// the output like this :
// JSON file generated at: lib/generated/user_data.json
// Dart class generated at: lib/generated/user_class.dart

  /*
      class User {
      String? name;
      String? age;
      User({
        this.name,
        this.age,
      });

      User.fromJson(Map<String, dynamic> json) {
        name = json["name"] ?? "";
        age = json["age"] ?? "";
      }

      Map<String, dynamic> toJson() => {
        "name": name ?? "",
        "age": age ?? "",
      };
    }
  */

  /* 
  {
  "name":"ahmed talal",
  "age":"26"
  }
  */
}
