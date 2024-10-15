import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';

class XmlConverterBase {
  /// Converts an XML string to a JSON file and saves it in the specified project structure.
  Future<void> convertXmlToJsonFile(
      String xmlString, String outputFileName) async {
    try {
      final xml2json = Xml2Json();
      xml2json.parse(xmlString);
      final jsonString = xml2json.toParker();
      final jsonObject = json.decode(jsonString);

      final outputDir = Directory('lib/generate');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final jsonFile = File('${outputDir.path}/$outputFileName.json');
      await jsonFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(jsonObject));
      print('JSON file generated at: ${jsonFile.path}');
    } catch (e) {
      print('Error generating JSON file: $e');
    }
  }

  /// Converts an XML string to a Dart class and saves it in the specified project structure.
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

      // Handle nested classes
      await _generateNestedClasses(buffer, xmlDocument.rootElement);

      // Specify the output directory in the project structure (lib/generated)
      final outputDir = Directory('lib/generate');
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
    for (final child in element.children.whereType<XmlElement>()) {
      // Check for nested structures and handle accordingly
      if (child.children.any((c) => c is XmlElement)) {
        buffer.writeln(
            '  List<${child.name.toString().capitalize()}>? ${child.name};'); // Use a List for nested structures
      } else if (element.children
              .where((c) => c is XmlElement && c.name == child.name)
              .length >
          1) {
        // If there are multiple siblings with the same name, make it a List
        buffer.writeln('  List<String>? ${child.name};');
      } else {
        buffer.writeln('  String? ${child.name};');
      }
    }
  }

  void _xmlToDartClassFromJson(StringBuffer buffer, XmlElement element) {
    for (final child in element.children.whereType<XmlElement>()) {
      if (child.children.any((c) => c is XmlElement)) {
        buffer.writeln(
            '    ${child.name} = json["${child.name}"] != null ? List<${child.name.toString().capitalize()}>.from(json["${child.name}"].map((item) => ${child.name.toString().capitalize()}.fromJson(item))) : null;');
      } else if (element.children
              .where((c) => c is XmlElement && c.name == child.name)
              .length >
          1) {
        // Handle multiple elements with the same name
        buffer.writeln(
            '    ${child.name} = json["${child.name}"] != null ? List<String>.from(json["${child.name}"].map((item) => item as String)) : null;');
      } else {
        buffer.writeln('    ${child.name} = json["${child.name}"];');
      }
    }
  }

  /// Generates code for a Dart class's `toJson` method based on the given
  /// [XmlElement].
  ///
  /// The generated code will recursively convert all nested structures
  /// (i.e. elements with children) to JSON objects, and all other elements
  /// will be converted to strings. If multiple elements with the same name are
  /// found, they will be converted to a List of strings.
  ///
  /// The generated code will be appended to the given [StringBuffer].
  void _xmlToDartClassToJson(StringBuffer buffer, XmlElement element) {
    for (final child in element.children.whereType<XmlElement>()) {
      if (child.children.any((c) => c is XmlElement)) {
        buffer.writeln(
            '    "${child.name}": ${child.name}?.map((item) => item.toJson()).toList(),');
      } else if (element.children
              .where((c) => c is XmlElement && c.name == child.name)
              .length >
          1) {
        // Handle multiple elements with the same name
        buffer.writeln('    "${child.name}": ${child.name},');
      } else {
        buffer.writeln('    "${child.name}": ${child.name},');
      }
    }
  }

  Future<void> _generateNestedClasses(
      StringBuffer buffer, XmlElement element) async {
    for (final child in element.children.whereType<XmlElement>()) {
      if (child.children.any((c) => c is XmlElement)) {
        final nestedClassName =
            child.name.toString().capitalize(); // Capitalize class name
        buffer.writeln();
        buffer.writeln('class $nestedClassName {');

        for (var grandChild in child.children.whereType<XmlElement>()) {
          buffer.writeln('  String? ${grandChild.name};');
        }

        buffer.writeln('  $nestedClassName({');
        for (var grandChild in child.children.whereType<XmlElement>()) {
          buffer.writeln('    this.${grandChild.name},');
        }
        buffer.writeln('  });');

        buffer.writeln();

        buffer.writeln(
            '  $nestedClassName.fromJson(Map<String, dynamic> json) {');
        for (var grandChild in child.children.whereType<XmlElement>()) {
          buffer
              .writeln('    ${grandChild.name} = json["${grandChild.name}"];');
        }
        buffer.writeln('  }');

        buffer.writeln('  Map<String, dynamic> toJson() => {');
        for (var grandChild in child.children.whereType<XmlElement>()) {
          buffer.writeln('    "${grandChild.name}": ${grandChild.name},');
        }
        buffer.writeln('  };');
        buffer.writeln('}');
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
