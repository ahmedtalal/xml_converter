import 'package:xml_converter/src/xml_converter_base.dart';

void main() async {
  final xmlConverter = XmlConverterBase();

  // create an XML string
  String jsonString = '''
<weatherInfo>
    <weather>sunny</weather>
    <clouds>no</clouds>
    <time>11.30</time>
    <sportsYouCanDo>
        <sport1>running</sport1>
        <sport2>hiking</sport2>
        <sport3>biking</sport3>
    </sportsYouCanDo>
    <anyMap>
        <key1>value 1</key1>
        <key2>value 2</key2>
    </anyMap>
</weatherInfo>
''';

  // convert XML to JSON and save it to a file
  await xmlConverter.convertXmlToJsonFile(jsonString, 'users');

  // convert JSON to Dart class and save it to a file
   xmlConverter.convertXmlToDartClass(jsonString, 'Users', 'users');
}
