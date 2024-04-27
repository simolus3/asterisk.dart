import 'package:asterisk/asterisk.dart';

Asterisk createAsteriskClient() {
  return Asterisk(
    baseUri: Uri.parse('http://localhost:8088'),
    applicationName: 'demo',
    username: 'demoapp',
    password: 'demo',
  );
}
