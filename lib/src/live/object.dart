import 'package:meta/meta.dart';

import '../asterisk.dart';
import '../definitions/ws_message.dart';
import '../event/source.dart';

/// A remote object managed by Asterisk.
@internal
abstract class LiveObject<Raw extends EventSource> implements EventSource {
  final AsteriskClient asterisk;
  final bool _subscribedByDefault;

  Raw _latest;

  Raw get latestSnapshot => _latest;

  LiveObject(this.asterisk, this._latest, this._subscribedByDefault);

  @override
  EventSourceDescription get description => _latest.description;

  void update(Raw latest) {
    _latest = latest;
  }

  void updateFromEvent(Event event);

  Stream<Event> get events {
    return asterisk.events
        .listenFor(source: this, needsSubscription: !_subscribedByDefault)
        .map((event) {
      updateFromEvent(event);
      return event;
    });
  }
}
