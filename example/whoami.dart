import 'package:asterisk/asterisk.dart';

import '_credentials.dart';

/// Accepts incoming calls, announces the caller id on the channel and then
/// hangs up.
void main() async {
  final asterisk = createAsteriskClient();
  print('Starting up - dial number 1 to reach whoami');

  await for (final incoming in asterisk.stasisStart) {
    _announceId(incoming.channel);
  }
}

Future<void> _announceId(LiveChannel channel) async {
  print('Has incoming call from ${channel.channel.caller}');

  await channel.answer();
  await Future.delayed(const Duration(seconds: 1));

  // This could be simplified by just supplying an array of sources in a single
  // play() call, but doing this manually shows some of the event-handling
  // capabilities.
  var playback =
      await channel.play(sources: [MediaSource.sound('hello-world')]);
  await playback.events.where((e) => e is PlaybackFinished).first;

  playback = await channel
      .play(sources: [MediaSource.digits(channel.channel.caller.number)]);
  await playback.events.where((e) => e is PlaybackFinished).first;

  if (!channel.isClosed) {
    await channel.hangUp();
  }
}
