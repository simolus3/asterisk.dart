import 'package:asterisk/asterisk.dart';
import 'package:async/async.dart';

import '_credentials.dart';

/// A simple voice-based timer system.
///
/// This accepts incoming calls, in which the caller is expected to enter a
/// duration in seconds using DTMF codes, followed by a number sign (`#`).
/// After doing that, the rest of the incoming call is recorded. After it ends,
/// this waits for the indicate duration and then calls back to play the
/// recording as a reminder.
void main() async {
  final asterisk = createAsteriskClient();
  print('Starting up - dial number 1 to set reminders');
  print('After the call is accepted, enter the time in seconds and press #.');
  print('You can then record a reminder - the timer starts as soon as you');
  print('hang up the call');

  await for (final incoming in asterisk.stasisStart) {
    if (incoming.args.isEmpty) {
      // Ignore requests with arguments - these are outgoing channels placed
      // into the application and not an incoming channel to handle
      VoiceReminder(asterisk).run(incoming.channel);
    }
  }
}

class VoiceReminder {
  final Asterisk asterisk;
  final StreamGroup<VoiceCallEvent> _events = StreamGroup();
  int durationInSeconds = 0;
  String? recordingName;
  LiveChannel? outgoing;
  bool outgoingPickedUp = false;

  VoiceReminder(this.asterisk);

  Future<void> run(LiveChannel incoming) async {
    await incoming.answer();

    final incomingEvents = incoming.events
        .map((event) {
          if (event case ChannelDtmfReceived(digit: final digit)) {
            return EnteredDigit(char: digit);
          }
          if (event is StasisEnd) {
            return HungUp();
          }
        })
        .where((e) => e is VoiceCallEvent)
        .cast<VoiceCallEvent>();
    _events.add(incomingEvents);

    await for (final event in _events.stream) {
      switch (event) {
        case EnteredDigit(char: '#'):
          // Start live recording for playback.
          final name = recordingName = incoming.channel.id;
          await incoming.record(
            name: name,
            format: 'wav',
            ifExists: RecordingExistsBehavior.overwrite,
          );
          break;
        case EnteredDigit(char: final digit):
          // Append digit to timer
          try {
            durationInSeconds = durationInSeconds * 10 + int.parse(digit);
          } on FormatException {
            // ignore
          }
        case HungUp():
          if (outgoing != null) {
            // The outgoing channel to which we're playing the recording hung
            // up. Delete the recording so that we don't leak disk space.
            await asterisk.api.recordings.deleteStored(recordingName!);
          } else if (durationInSeconds > 0) {
            // The incoming call hung up after we've started the voice
            // recording. Start the timer now!
            _events.add(
              Stream.fromFuture(Future.delayed(
                Duration(seconds: durationInSeconds),
                () => TimerExpired(),
              )),
            );
          }
          _events.remove(incomingEvents);
        case ReplayFinished():
          await outgoing?.hangUp();
          return;
        case TimerExpired():
          // Call the user again, and play back the recorded timer.
          final channel = outgoing = await asterisk.createChannel(
            endpoint: 'PJSIP/${incoming.channel.caller.number}',
            appArgs: 'outgoing',
            formats: ['opus', 'ulaw'],
            variables: {
              'CALLERID(name)': 'Scheduled reminder',
              'CALLERID(number)': '1',
            },
          );
          await channel.dial(timeout: const Duration(minutes: 1));
          _events.add(channel.events
              .map((event) {
                if (event is StasisEnd) {
                  return HungUp();
                } else if (event is ChannelStateChange &&
                    !outgoingPickedUp &&
                    channel.channel.state == ChannelState.up) {
                  outgoingPickedUp = true;
                  return PickedUp();
                }
              })
              .where((e) => e is VoiceCallEvent)
              .cast());
        case PickedUp():
          final playback = await outgoing!
              .play(sources: [MediaSource.recording(recordingName!)]);
          _events.add(playback.events
              .map((event) {
                if (event is PlaybackFinished) {
                  return ReplayFinished();
                }
              })
              .where((e) => e is VoiceCallEvent)
              .cast());
      }
    }
  }
}

sealed class VoiceCallEvent {}

final class EnteredDigit implements VoiceCallEvent {
  final String char;

  EnteredDigit({required this.char});
}

final class HungUp implements VoiceCallEvent {}

final class PickedUp implements VoiceCallEvent {}

final class ReplayFinished implements VoiceCallEvent {}

final class TimerExpired implements VoiceCallEvent {}
