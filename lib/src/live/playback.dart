import 'package:asterisk/src/definitions/ws_message.dart';

import '../definitions/playback.dart';
import 'object.dart';

/// A playback of media on a channel or bridge.
///
/// The [events] stream can be used to determine when the playback has
/// completed.
final class LivePlayback extends LiveObject<Playback> {
  LivePlayback(super.asterisk, super.latest, super.subscribedByDefault);

  @override
  void updateFromEvent(Event event) {
    if (event case HasPlayback(:final playback)) {
      update(playback);
    }
  }

  /// Stops this playback.
  Future<void> stop() async {
    await asterisk.api.playbacks.stop(latestSnapshot.id);
  }

  /// Sends the [PlaybackControl] command to this playback.
  Future<void> control(PlaybackControl control) async {
    await asterisk.api.playbacks.control(latestSnapshot.id, control.name);
  }
}

enum PlaybackControl {
  restart,
  pause,
  unpause,
  reverse,
  forward,
}
