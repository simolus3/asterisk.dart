/// Dart bindings to the [Asterisk RESTful interface](https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/).
///
/// The [Asterisk] class is the main entrypoint bundling all available
/// functionality. It can be used to connect to Asterisk and handle calls passed
/// to an application:
///
/// ```dart
/// import 'package:asterisk/asterisk.dart';
///
/// void main() async {
///   final asterisk = Asterisk(
///     baseUri: Uri.parse('http://localhost:8088'),
///     applicationName: 'demo',
///     username: 'demoapp',
///     password: 'demo',
///   );
///   await for (final incoming in asterisk.stasisStart) {
///     _announceId(incoming.channel);
///   }
/// }
///
/// Future<void> _announceId(LiveChannel channel) async {
///   print('Has incoming call from ${channel.channel.caller}');
///
///   await channel.answer();
///   await Future.delayed(const Duration(seconds: 1));
///
///   final playback = await channel
///       .play(sources: [MediaSource.digits(channel.channel.caller.number)]);
///   // Wait for the playback to finish.
///   await playback.events.where((e) => e is PlaybackFinished).first;
///
///   if (!channel.isClosed) {
///     await channel.hangUp();
///   }
/// }
/// ```
///
/// Also see the [repository](https://github.com/simolus3/asterisk.dart) for
/// its readme and more details.
library asterisk;

import 'dart:convert';

export 'src/definitions/bridge.dart';
export 'src/definitions/channel.dart';
export 'src/definitions/playback.dart' show MediaSource;
export 'src/definitions/ws_message.dart';
export 'src/live/bridge.dart';
export 'src/live/channel.dart';
export 'src/live/endpoint.dart';
export 'src/live/playback.dart';
export 'src/live/recording.dart';

import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'src/api.dart';
import 'src/asterisk.dart';
import 'src/definitions/bridge.dart';
import 'src/interceptors.dart';
import 'src/live/bridge.dart';
import 'src/live/channel.dart';
import 'src/live/endpoint.dart';

/// An event emitted by [Asterisk.stasisStart] when a channel is placed into
/// this application.
typedef StasisStart = ({List<String> args, LiveChannel channel});

/// A client to the Asterisk RESTful API as well as its event notification
/// system through websockets.
abstract interface class Asterisk {
  /// Access to the raw ARI api.
  AsteriskApi get api;

  /// The name of this application.
  String get applicationName;

  /// Creates a new Asterisk client from the [baseUri] to connect to as well
  /// as application credentials ([username] and [password] as well as the
  /// [applicationName] to register).
  ///
  /// The [baseUri] should not contain the `ari/` path, just the host of the
  /// server. So if your Asterisk is available under `https://asterisk.example.com/ari`,
  /// the [baseUri] should be `https://asterisk.example.com/`.
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

  /// A future completing when the web socket channel to Asterisk has been
  /// set up.
  ///
  /// Asterisk is using web socket to notify clients about incoming events, so
  /// this package is setting up a web socket connection automatically.
  Future<void> get webSocketReady;

  /// Closes pending requests and the web socket notification to Asterisk.
  ///
  /// This does not automatically hang up channels or other Asterisk resources
  /// initiated by this application.
  Future<void> close();

  /// A stream of channels and arguments passed to this application.
  ///
  /// This stream emits an event everytime a channel is placed into this
  /// application via the `Stasis` dialplan function, but also for calls
  /// created or initiated by this application.
  ///
  /// Typically, ARI applications would listen to this stream to start handling
  /// incoming calls.
  Stream<StasisStart> get stasisStart;

  /// A list of all endpoints registered to Asterisk.
  ///
  ///
  Future<List<LiveEndpoint>> get endpoints;

  Future<LiveBridge> createBridge({
    required String name,
    required Iterable<BridgeType> types,
  });

  /// Creates a new channel.
  ///
  /// The channel will be posted towards the stasis application given in
  /// [applicationName] (defaults to the current application). So in addition to
  /// the [LiveChannel] returned by this call, the channel will also be posted
  /// to [stasisStart].
  ///
  /// Asterisk docs: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#create
  Future<LiveChannel> createChannel({
    String? applicationName,
    required String endpoint,
    String? appArgs,
    String? channelId,
    String? otherChannelId,
    String? originator,
    Iterable<String>? formats,
    Map<String, String>? variables,
  });
}
