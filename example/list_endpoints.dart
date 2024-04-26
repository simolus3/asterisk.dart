import '_credentials.dart';

/// Lists all endpoints registered to the Asterisk instance and logs events as
/// they come online and offline.
void main() async {
  final asterisk = createAsteriskClient();

  for (final endpoint in await asterisk.endpoints) {
    final desc = endpoint.endpoint;
    print('Asterisk has endpoint: ${desc.technology}/${desc.resource}');

    endpoint.events.listen((event) {
      print(
          'Saw event $event on ${desc.resource}. State now: ${endpoint.endpoint}');
    });
  }
}
