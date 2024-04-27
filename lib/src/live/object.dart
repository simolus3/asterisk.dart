import 'package:meta/meta.dart';

import '../asterisk.dart';
import '../definitions/ws_message.dart';
import '../event/source.dart';

/// A remote object managed by Asterisk.
///
/// This package follows the "live object" pattern to call methods on these
/// objects through the REST interface. Similarly, incoming events for objects
/// are dispatched using Dart streams ([events]).
@internal
abstract class LiveObject<Raw extends EventSource> implements EventSource {
  /// The asterisk instance backing this live object.
  final AsteriskClient asterisk;
  final bool _subscribedByDefault;

  Raw _latest;

  /// The latest snapshot of the [Raw] API object as returned by Asterisk.
  Raw get latestSnapshot => _latest;

  LiveObject(this.asterisk, this._latest, this._subscribedByDefault);

  @override
  EventSourceDescription get description => _latest.description;

  /// Updates the [latestSnapshot] with new information received from Asterisk.
  void update(Raw latest) {
    _latest = latest;
  }

  /// Update the [latestSnapshot] of this object based on the received event.
  @protected
  void updateFromEvent(Event event);

  /// A stream of [Event]s affecting this object.
  Stream<Event> get events {
    return asterisk.events
        .listenFor(source: this, needsSubscription: !_subscribedByDefault)
        .map((event) {
      updateFromEvent(event);
      return event;
    });
  }
}
