import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml_converter/xml_converter.dart';
void main() {
  late XmlConverterBase xmlConverter;

  setUp(() {
    xmlConverter = XmlConverterBase();
  });

  test('convertXmlToJsonFile generates JSON file', () async {
    final xmlString = '''
      <root>
        <item>Value 1</item>
        <item>Value 2</item>
      </root>
    ''';

    final outputFileName = 'test_output';
    
    // Ensure the directory does not exist before test
    final outputDir = Directory('lib/generate');
    if (await outputDir.exists()) {
      await outputDir.delete(recursive: true);
    }

    await xmlConverter.convertXmlToJsonFile(xmlString, outputFileName);

    final jsonFile = File('${outputDir.path}/$outputFileName.json');
    expect(await jsonFile.exists(), isTrue);

    // Clean up
    await jsonFile.delete();
  });

  test('convertXmlToDartClass generates Dart class file', () async {
    final xmlString = '''
      <root>
        <item>
          <name>Item Name</name>
          <value>Item Value</value>
        </item>
      </root>
    ''';

    final className = 'Item';
    final outputFileName = 'item_class';

    // Ensure the directory does not exist before test
    final outputDir = Directory('lib/generate');
    if (await outputDir.exists()) {
      await outputDir.delete(recursive: true);
    }

    await xmlConverter.convertXmlToDartClass(xmlString, className, outputFileName);

    final dartFile = File('${outputDir.path}/$outputFileName.dart');
    expect(await dartFile.exists(), isTrue);

    // Verify content in the generated Dart file
    final content = await dartFile.readAsString();
    expect(content, contains('class $className'));
    expect(content, contains('String? name;'));
    expect(content, contains('String? value;'));

    // Clean up
    await dartFile.delete();
  });

  tearDown(() async {
    final outputDir = Directory('lib/generate');
    if (await outputDir.exists()) {
      await outputDir.delete(recursive: true);
    }
  });
}
