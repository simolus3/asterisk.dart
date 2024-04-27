import 'package:asterisk/src/definitions/ws_message.dart';

import '../definitions/endpoint.dart';
import 'object.dart';

/// An endpoint is a logical device (such as a phone) that can be connected to
/// Asterisk.
///
/// This [LiveObject] allows listening for the state of endpoint.
final class LiveEndpoint extends LiveObject<Endpoint> {
  LiveEndpoint(super.asterisk, super._latest, super._subscribedByDefault);

  Endpoint get endpoint => latestSnapshot;

  @override
  void updateFromEvent(Event event) {
    if (event is EndpointStateChange) {
      update(event.endpoint);
    }
  }
}
