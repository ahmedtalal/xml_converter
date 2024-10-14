import 'dart:io';

import 'package:test/test.dart';
import 'package:xml_converter/xml_converter.dart';

void main() {
  group('XmlConverterBase Tests', () {
    final xmlConverter = XmlConverterBase();

    const xmlString = '<user><name>John Doe</name><age>30</age></user>';

    test('Convert XML string to JSON string', () async {
      // Create a temporary directory for the test output
      final outputFileName = 'test_output';

      // Convert XML to JSON
      await xmlConverter.convertXmlToJsonFile(xmlString, outputFileName);

      // Check if the JSON file has been created and read its content
      final jsonFile = File('lib/generated/$outputFileName.json');
      expect(await jsonFile.exists(), isTrue);
      
      final jsonContent = await jsonFile.readAsString();
      expect(jsonContent, '{"name":"John Doe","age":"30"}');

      // Clean up the generated file
      await jsonFile.delete();
    });

    test('Convert XML string to Dart class string', () async {
      // Create a temporary directory for the test output
      final className = 'User';
      final outputFileName = 'user_class_output';

      // Convert XML to Dart class
      await xmlConverter.convertXmlToDartClass(xmlString, className, outputFileName);

      // Check if the Dart class file has been created and read its content
      final dartFile = File('lib/generated/$outputFileName.dart');
      expect(await dartFile.exists(), isTrue);
      
      final dartContent = await dartFile.readAsString();
      expect(dartContent, contains('class $className {'));
      expect(dartContent, contains('String? name;'));
      expect(dartContent, contains('String? age;'));
      expect(dartContent, contains('$className.fromJson'));
      expect(dartContent, contains('toJson() => {'));

      // Clean up the generated file
      await dartFile.delete();
    });
  });
}
