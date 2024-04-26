import 'package:asterisk/src/definitions/ws_message.dart';
import 'package:asterisk/src/live/object.dart';

import '../definitions/bridge.dart';

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
