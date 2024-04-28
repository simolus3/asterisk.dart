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

  /// Adds the [channels] to this bridge, forwarding media between them.
  ///
  /// If [absorbDTMF] is set (it defaults to `false`), DTMF events from the
  /// channel are not forwarded into the bridge.
  /// If [mute] is set (defaults to `false`), audio from the channel is not
  /// forwarded into the bridge.
  /// If [inhibitConnectedLineUpdates] is set (defaults to `false`), the
  /// identity of the newly connected channels is not presented to other bridge
  /// members.
  /// Also see the [Asterisk docs].
  ///
  /// [Asterisk docs]: https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Bridges_REST_API/#addchannel
  Future<void> addChannels(
    Iterable<String> channels, {
    bool absorbDTMF = false,
    bool mute = false,
    bool inhibitConnectedLineUpdates = false,
  }) async {
    await asterisk.api.bridges.addChannel(
      bridge: latestSnapshot.id,
      channel: channels.join(','),
      absorbDTMF: absorbDTMF,
      mute: mute,
      inhibitConnectedLineUpdates: inhibitConnectedLineUpdates,
    );
  }

  Future<void> destroy() async {
    await asterisk.api.bridges.destroy(latestSnapshot.id);
  }

  @override
  void updateFromEvent(Event event) {}
}
