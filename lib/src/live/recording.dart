import 'package:asterisk/src/definitions/ws_message.dart';

import '../definitions/recordings.dart';
import 'object.dart';

class LiveRecording extends LiveObject<Recording> {
  LiveRecording(super.asterisk, super.latest, super.subscribedByDefault);

  @override
  void updateFromEvent(Event event) {
    if (event case RecordingEvent(:final recording)) {
      update(recording);
    }
  }
}
