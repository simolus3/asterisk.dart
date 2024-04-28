import 'package:asterisk/asterisk.dart';
import 'package:async/async.dart';
import 'package:test/test.dart';

import 'mock_server.dart';

void main() {
  late Asterisk asterisk;
  late MockServer server;

  setUp(() async {
    server = await MockServer.open();
    asterisk = server.createClient();
  });

  tearDown(() async {
    await asterisk.close();
    await server.stop();
  });

  test('receives events from web sockets', () async {
    await asterisk.webSocketReady;
    expect(server.channels, hasLength(1));
    expect(
      asterisk.stasisStart,
      emits(isA<StasisStart>()
          .having((e) => e.args, 'args', ['foo', 'bar']).having(
              (e) => e.channel.channel.id, 'channel.id', 'test-channel')),
    );

    server.broadcastMessage(MockServer.event({
      'type': 'StasisStart',
      'channel': testChannel,
      'application': 'demo',
      'args': ['foo', 'bar'],
    }));
  });

  test('disconnects from web socket after closing', () async {
    await asterisk.webSocketReady;
    await asterisk.close();
    await Future.delayed(const Duration(milliseconds: 500));
    expect(server.channels, isEmpty);
  });

  group('channels', () {
    late LiveChannel receivedChannel;

    setUp(() async {
      await asterisk.webSocketReady;
      final stasisStart = StreamQueue(asterisk.stasisStart);

      server.broadcastMessage(MockServer.event({
        'type': 'StasisStart',
        'channel': testChannel,
        'args': ['foo', 'bar'],
      }));

      receivedChannel = (await stasisStart.next).channel;
      stasisStart.cancel();
    });

    test('set ringing', () async {
      server.registerHandler('ari/channels/test-channel/ring', 'POST',
          expectAsync1((request) => MockServer.json(null)));
      await receivedChannel.startRinging();

      server.registerHandler('ari/channels/test-channel/ring', 'DELETE',
          expectAsync1((request) => MockServer.json(null)));
      await receivedChannel.stopRinging();
    });

    test('hang up', () async {
      server.registerHandler('ari/channels/test-channel', 'DELETE',
          expectAsync1((request) => MockServer.json(null)));
      await receivedChannel.hangUp();
    });

    test('is updated from events', () async {
      final queue = StreamQueue(receivedChannel.events);
      server.broadcastMessage(MockServer.event({
        'type': 'ChannelDtmfReceived',
        'channel': {
          ...testChannel,
          'state': 'Busy',
        },
        'digit': '3',
        'duration_ms': 70,
      }));

      expect(
        await queue.next,
        isA<ChannelDtmfReceived>()
            .having((e) => e.digit, 'digit', '3')
            .having((e) => e.duration, 'duration', Duration(milliseconds: 70)),
      );

      // Processing the event should update the channel snapshot
      expect(receivedChannel.channel.state, ChannelState.busy);
      server.broadcastMessage(MockServer.event({
        'type': 'StasisEnd',
        'channel': testChannel,
      }));

      await queue.next;
      expect(receivedChannel.isClosed, isTrue);
      expect(() => receivedChannel.dial(), throwsStateError, reason: '');
    });
  });
}
