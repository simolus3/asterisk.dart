import 'package:asterisk/src/definitions/ws_message.dart';

import '../definitions/recordings.dart';
import 'object.dart';

/// An in-progress recording happening on a channel or bridge.
///
/// The [events] stream can be used to get notified when the recording is
/// completed. Similarly, methods on this class can be used to stop a recording
/// after it has been started.
class LiveRecording extends LiveObject<Recording> {
  LiveRecording(super.asterisk, super.latest, super.subscribedByDefault);

  @override
  void updateFromEvent(Event event) {
    if (event case RecordingEvent(:final recording)) {
      update(recording);
    }
  }

  /// Stops this recording and then discards it.
  Future<void> cancel() async {
    await asterisk.api.recordings.deleteLive(latestSnapshot.name);
  }

  /// Stops this recording and persists it.
  ///
  /// [name] is the name of the stored recording, which defaults to the name of
  /// this live recording.
  Future<void> stopAndStore({String? name}) async {
    await asterisk.api.recordings.stopAndStoreLive(latestSnapshot.name,
        recordingName: name ?? latestSnapshot.name);
  }
}
