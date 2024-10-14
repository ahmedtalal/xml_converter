import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';

class XmlConverterBase {
   /// Converts an XML string to a JSON file and saves it in the specified project structure.
  Future<void> convertXmlToJsonFile(String xmlString, String outputFileName) async {
    try {
      final xmlDocument = XmlDocument.parse(xmlString);

      // Convert XML to JSON
      final jsonMap = _xmlToJson(xmlDocument.rootElement);
      final jsonString = jsonEncode(jsonMap);

      // Specify the output directory in the project structure (lib/generated)
      final outputDir = Directory('lib/generated');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Create the JSON file in the project structure
      final jsonFile = File('${outputDir.path}/$outputFileName.json');
      await jsonFile.writeAsString(jsonString);

      print('JSON file generated at: ${jsonFile.path}');
    } catch (e) {
      print('Error converting XML to JSON: $e');
    }
  }

   /// Helper function to convert an XML element to a JSON map.
  Map<String, dynamic> _xmlToJson(XmlElement element) {
    final Map<String, dynamic> json = {};

    // Handle attributes
    for (var attribute in element.attributes) {
      json['@${attribute.name}'] = attribute.value;
    }

    // Handle children
    for (var child in element.children) {
      if (child is XmlElement) {
        // Directly assign the text content to the key instead of wrapping it
        final childText = child.text.trim();
        if (childText.isNotEmpty) {
          json[child.name.toString()] = childText;
        }
      } else if (child is XmlText) {
        // If the child is text, we need to capture its value
        final trimmedValue = child.value.trim(); // Use the XmlData.value getter
        if (trimmedValue.isNotEmpty) {
          json['#text'] = trimmedValue;
        }
      }
    }

    // Handle the case where the element has no children and contains text
    if (element.children.isEmpty && element.value!.trim().isNotEmpty) {
      json['#text'] = element.value?.trim(); // Use the XmlData.value getter
    }
    return json;
  }
  /// Converts an XML string to a Dart class and saves it in the project structure.
  Future<void> convertXmlToDartClass(
      String xmlString, String className, String outputFileName) async {
    try {
      final xmlDocument = XmlDocument.parse(xmlString);

      final buffer = StringBuffer();

      // Start building the Dart class
      buffer.writeln('class $className {');

      // Parse XML elements into Dart fields
      _xmlToDartClassFields(buffer, xmlDocument.rootElement);

      // Constructor
      buffer.writeln('  $className({');

      xmlDocument.rootElement.children.whereType<XmlElement>().forEach((child) {
        buffer.writeln('    this.${child.name},');
      });
      buffer.writeln('  });');

      buffer.writeln();

      // Generate fromJson constructor
      buffer.writeln('  $className.fromJson(Map<String, dynamic> json) {');
      _xmlToDartClassFromJson(buffer, xmlDocument.rootElement);
      buffer.writeln('  }');

      // Generate toJson method
      buffer.writeln('  Map<String, dynamic> toJson() => {');
      _xmlToDartClassToJson(buffer, xmlDocument.rootElement);
      buffer.writeln('  };');

      buffer.writeln('}');

      // Specify the output directory in the project structure (lib/generated)
      final outputDir = Directory('lib/generated');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Write the generated Dart class to the file in the project structure
      final dartFile = File('${outputDir.path}/$outputFileName.dart');
      await dartFile.writeAsString(buffer.toString());

      print('Dart class file generated at: ${dartFile.path}');
    } catch (e) {
      print('Error converting XML to Dart class: $e');
    }
  }

  void _xmlToDartClassFields(StringBuffer buffer, XmlElement element) {
    // Iterate through attributes and children
    for (final attribute in element.attributes) {
      buffer.writeln('  String? ${attribute.name};');
    }
    for (final child in element.children.whereType<XmlElement>()) {
      buffer.writeln('  String? ${child.name};');
    }
  }

  void _xmlToDartClassFromJson(StringBuffer buffer, XmlElement element) {
    for (final attribute in element.attributes) {
      buffer
          .writeln('    ${attribute.name} = json["${attribute.name}"] ?? "";');
    }
    for (final child in element.children.whereType<XmlElement>()) {
      buffer.writeln('    ${child.name} = json["${child.name}"] ?? "";');
    }
  }

  void _xmlToDartClassToJson(StringBuffer buffer, XmlElement element) {
    for (final attribute in element.attributes) {
      buffer.writeln('    "${attribute.name}": ${attribute.name} ?? "",');
    }
    for (final child in element.children.whereType<XmlElement>()) {
      buffer.writeln('    "${child.name}": ${child.name} ?? "",');
    }
  }
}
