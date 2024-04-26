import '../definitions/channel.dart';
import '../definitions/playback.dart';
import '../definitions/ws_message.dart';
import 'object.dart';
import 'playback.dart';

final class LiveChannel extends LiveObject<Channel> {
  LiveChannel(super.asterisk, super.latest, super.subscribedByDefault);

  bool _closed = false;

  Channel get channel => latestSnapshot;

  bool get isClosed => _closed;

  void _markClosed() {
    _closed = true;
  }

  void _checkNotClosed() {
    if (_closed) {
      throw StateError('This channel is closed');
    }
  }

  Future<void> answer() async {
    _checkNotClosed();
    await asterisk.api.channels.answer(channel.id);
  }

  Future<void> startRinging() async {
    _checkNotClosed();
    await asterisk.api.channels.startRinging(channel.id);
  }

  Future<void> stopRinging() async {
    _checkNotClosed();
    await asterisk.api.channels.stopRinging(channel.id);
  }

  Future<void> hangUp() async {
    _checkNotClosed();
    await asterisk.api.channels.hangup(channel.id);
  }

  Future<LivePlayback> play({required Iterable<MediaSource> sources}) async {
    _checkNotClosed();
    final response = await asterisk.api.channels.play(
      channel.id,
      sources.map((e) => e.uri.toString()).join(','),
    );
    return asterisk.recognizeLiveObject(
        response, (raw) => LivePlayback(asterisk, raw, true));
  }

  @override
  void updateFromEvent(Event event) {
    if (event case HasChannel(:final channel)) {
      update(channel);
    }

    if (event is StasisEnd || event is ChannelDestroyed) {
      _markClosed();
    }
  }
}
