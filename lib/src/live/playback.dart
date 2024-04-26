import 'package:asterisk/src/definitions/ws_message.dart';

import '../definitions/playback.dart';
import 'object.dart';

final class LivePlayback extends LiveObject<Playback> {
  LivePlayback(super.asterisk, super.latest, super.subscribedByDefault);

  @override
  void updateFromEvent(Event event) {
    if (event case HasPlayback(:final playback)) {
      update(playback);
    }
  }
}
