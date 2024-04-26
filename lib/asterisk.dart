library asterisk;

import 'dart:convert';

export 'src/definitions/bridge.dart';
export 'src/definitions/playback.dart' show MediaSource;
export 'src/definitions/ws_message.dart';
export 'src/live/bridge.dart';
export 'src/live/channel.dart';
export 'src/live/endpoint.dart';
export 'src/live/playback.dart';

import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'src/api.dart';
import 'src/asterisk.dart';
import 'src/definitions/bridge.dart';
import 'src/interceptors.dart';
import 'src/live/bridge.dart';
import 'src/live/channel.dart';
import 'src/live/endpoint.dart';

typedef StasisStart = ({List<String> args, LiveChannel channel});

abstract interface class Asterisk {
  /// Access to the raw ARI api.
  AsteriskApi get api;
  String get applicationName;

  factory Asterisk({
    required Uri baseUri,
    required String applicationName,
    required String username,
    required String password,
    Client? client,
  }) {
    Client resolvedClient;
    Client? createdClient;
    if (client != null) {
      resolvedClient = client;
    } else {
      resolvedClient = createdClient = Client();
    }

    final api = AsteriskApi(
      baseUri.resolve('ari/'),
      ThrowOnError(
        AddHeaders(resolvedClient, headers: {
          'Authorization':
              'Basic ${base64.encode(utf8.encode('$username:$password'))}'
        }),
      ),
    );
    final channel =
        WebSocketChannel.connect(baseUri.resolve('ari/events').replace(
      scheme: switch (baseUri.scheme) {
        'https' => 'wss',
        _ => 'ws',
      },
      queryParameters: {
        'api_key': '$username:$password',
        'app': applicationName,
      },
    ));

    return AsteriskClient(
      api: api,
      channel: channel,
      applicationName: applicationName,
      ownedClient: createdClient,
    );
  }

  Future<void> close();

  Stream<StasisStart> get stasisStart;
  Future<List<LiveEndpoint>> get endpoints;

  Future<LiveBridge> createBridge({
    required String name,
    required Iterable<BridgeType> types,
  });
}
