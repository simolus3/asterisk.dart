import '../definitions/channel.dart';
import '../definitions/playback.dart';
import '../definitions/ws_message.dart';
import 'object.dart';
import 'playback.dart';
import 'recording.dart';

/// A channel between this Asterisk server and another device.
///
/// This is a [LiveObject], meaning that it will automatically update as this
/// package receives update events from Asterisk.
/// For more information on channels, see [Asterisk Channels].
///
/// [Asterisk Channels]: https://docs.asterisk.org/Fundamentals/Key-Concepts/Channels/
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

  /// Answers this channel.
  ///
  /// Throws if the channel cannot be answered (e.g. because it's not an
  /// incoming channel).
  Future<void> answer() async {
    _checkNotClosed();
    await asterisk.api.channels.answer(channel.id);
  }

  /// Starts playing a ring indication tone on this channel.
  Future<void> startRinging() async {
    _checkNotClosed();
    await asterisk.api.channels.startRinging(channel.id);
  }

  /// Stops playing a ring indication tone on this channel.
  Future<void> stopRinging() async {
    _checkNotClosed();
    await asterisk.api.channels.stopRinging(channel.id);
  }

  /// Destroys this channel by hanging up.
  Future<void> hangUp() async {
    _checkNotClosed();
    await asterisk.api.channels.hangup(channel.id);
  }

  /// Dials a channel created with [Asterisk.createChannel].
  Future<void> dial({Duration? timeout}) async {
    _checkNotClosed();
    await asterisk.api.channels.dial(channel.id, timeout?.inSeconds);
  }

  /// Creates a recording on this channel.
  ///
  /// The recording can later be stopped and saved or destroyed using the
  /// methods on [LiveRecording].
  /// [name] is the name of the recording (which Asterisk directly translates
  /// into a file path). [ifExists] controls what should happen if a recording
  /// with the same name already exists. An exception is thrown by default, but
  /// you can also choose to append or overwrite the existing recording.
  /// [maxDuration] and [maxSilence] automatically stop the recording after it
  /// exceeds a given duration or if no voice is detected for a set time.
  /// [beep] can be used to control whether a beep should be played on the
  /// channel prior to the recording.
  /// [terminateOn] allows listening for DTMF inputs that will automatically
  /// terminate the recording.
  ///
  /// For more information, see the [API docs].
  ///
  /// [API docs]: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#record
  Future<LiveRecording> record({
    required String name,
    required String format,
    Duration? maxDuration,
    Duration? maxSilence,
    bool beep = false,
    String terminateOn = 'none',
    RecordingExistsBehavior ifExists = RecordingExistsBehavior.fail,
  }) async {
    final response = await asterisk.api.channels.record(
      channel.id,
      name: name,
      format: format,
      maxDurationSeconds: maxDuration?.inSeconds ?? 0,
      maxSilenceSeconds: maxSilence?.inSeconds ?? 0,
      beep: beep,
      ifExists: ifExists.name,
      terminateOn: terminateOn,
    );

    return asterisk.recognizeLiveObject(
        response, (raw) => LiveRecording(asterisk, raw, true));
  }

  /// Plays a sequence of sounds of this channel.
  ///
  /// The playback can be controlled through the returned [LivePlayback] object.
  /// For valid sources, see [MediaSource] and the [API docs].
  ///
  /// [API docs]: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Channels_REST_API/#play
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

/// The behavior Asterisk should follow when [LiveChannel.record] is called but
/// a recording with the same name already exists.
enum RecordingExistsBehavior {
  /// Reject the new recording.
  fail,

  /// Overwrite the existing recording.
  overwrite,

  /// Append the new recording onto the existing snippet.
  append,
}
