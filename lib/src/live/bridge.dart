import 'package:asterisk/src/definitions/ws_message.dart';
import 'package:asterisk/src/live/object.dart';

import '../definitions/bridge.dart';

/// A construct sharing media between different channels.
///
/// This is a [LiveObject], meaning that it will automatically update as this
/// package receives update events from Asterisk.
/// For more information on channels, see [Asterisk Bridges].
///
/// [Asterisk Bridges]: https://docs.asterisk.org/Fundamentals/Key-Concepts/Bridges/
final class LiveBridge extends LiveObject<Bridge> {
  LiveBridge(super.asterisk, super.latest, super.subscribedByDefault);

  Future<void> addChannels(Iterable<String> channels) async {
    await asterisk.api.bridges.addChannel(
      bridge: latestSnapshot.id,
      channel: channels.join(','),
    );
  }

  Future<void> destroy() async {
    await asterisk.api.bridges.destroy(latestSnapshot.id);
  }

  @override
  void updateFromEvent(Event event) {}
}
