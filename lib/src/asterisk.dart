import 'dart:async';

import 'package:asterisk/src/live/endpoint.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:weak_cache/weak_cache.dart';

import '../asterisk.dart' as lib;
import 'api.dart';
import 'definitions/bridge.dart';
import 'definitions/ws_message.dart';
import 'event/distributor.dart';
import 'event/source.dart';
import 'live/bridge.dart';
import 'live/channel.dart';
import 'live/object.dart';

final class AsteriskClient implements lib.Asterisk {
  @override
  final AsteriskApi api;
  final WebSocketChannel channel;
  @override
  final String applicationName;

  final Client? _ownedClient;

  final StreamController<lib.StasisStart> _newChannels = StreamController();
  late final AsteriskEvents events = AsteriskEvents(this);

  final WeakCache<EventSourceDescription, LiveObject> _liveObjects =
      WeakCache();

  AsteriskClient({
    required this.api,
    required this.channel,
    required this.applicationName,
    required Client? ownedClient,
  }) : _ownedClient = ownedClient {
    events.globalEvents.listen((event) {
      if (event is StasisStart) {
        final channel = recognizeLiveObject(
            event.channel, (raw) => LiveChannel(this, event.channel, true));
        _newChannels.add((args: event.args, channel: channel));
      }
    });
  }

  @override
  Future<void> close() async {
    _ownedClient?.close();
  }

  L recognizeLiveObject<L extends LiveObject<R>, R extends EventSource>(
      R raw, L Function(R) wrap) {
    final object =
        _liveObjects.putIfAbsent(raw.description, () => wrap(raw)) as L;
    object.update(raw);
    return object;
  }

  @override
  Stream<lib.StasisStart> get stasisStart => _newChannels.stream;

  @override
  Future<List<LiveEndpoint>> get endpoints async {
    final rawEndpoints = await api.listEndpoints();
    return [
      for (final endpoint in rawEndpoints)
        recognizeLiveObject(endpoint, (raw) => LiveEndpoint(this, raw, false))
    ];
  }

  @override
  Future<LiveBridge> createBridge({
    required String name,
    required Iterable<BridgeType> types,
  }) async {
    final response = await api.bridges
        .createBridge(name: name, type: types.map((e) => e.name).join(','));
    return recognizeLiveObject(response, (raw) => LiveBridge(this, raw, true));
  }

  @override
  Future<LiveChannel> createChannel({
    String? applicationName,
    required String endpoint,
    String? appArgs,
    String? channelId,
    String? otherChannelId,
    String? originator,
    Iterable<String>? formats,
    Map<String, String>? variables,
  }) async {
    final channel = await api.channels.createChannel(
      endpoint: endpoint,
      app: applicationName ?? this.applicationName,
      appArgs: appArgs,
      channelId: channelId,
      originator: originator,
      otherChannelId: otherChannelId,
      formats: formats,
      variables: variables,
    );

    return recognizeLiveObject(channel, (raw) => LiveChannel(this, raw, true));
  }
}
