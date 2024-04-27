import 'package:asterisk/asterisk.dart';
import 'package:async/async.dart';

import '_credentials.dart';

/// A very simple roulette routing between incoming calls.
///
/// The first incoming call is added to a wait list until someone else is
/// calling this application. The two calls are then connected (into a virtual
/// line that we destroy as soon as one of them hangs up).
void main() async {
  final asterisk = createAsteriskClient();
  final roulette = CallRoulette(asterisk);
  print('Starting up - dial number 1 to reach the call roulette service');

  await for (final incoming in asterisk.stasisStart) {
    roulette.addCall(incoming.channel);
  }
}

class CallRoulette {
  final Asterisk asterisk;
  // Used to listen for hang ups across channels.
  final StreamGroup _stream = StreamGroup();

  final Map<LiveChannel, CallState> _activeCalls = {};
  final List<LiveChannel> _waitingForPartners = [];
  int _bridgeCounter = 0;

  CallRoulette(this.asterisk) {
    _stream.stream.listen(null);
  }

  void addCall(LiveChannel incoming) async {
    print('Incoming call from ${incoming.channel.caller}');
    await incoming.answer();

    // Can we connect this call to one currently pending?
    if (_waitingForPartners.isNotEmpty) {
      final waiting = _waitingForPartners.removeAt(0);
      print('=> Connecting with ${waiting.channel.caller}');

      // Create a bridge to connect these two channels.
      final bridge = await asterisk.createBridge(
        name: 'call-roulette-${_bridgeCounter++}',
        types: [BridgeType.mixing],
      );

      final call = ConnectedCall(incoming, waiting, bridge);
      await waiting.stopRinging();

      _activeCalls[waiting] = call;
      _activeCalls[incoming] = call;

      await bridge.addChannels([incoming.channel.id, waiting.channel.id]);
    } else {
      print('=> No one to connect to right now, putting into wait list');
      await incoming.startRinging();
      _activeCalls[incoming] = const WaitingForPartner();
      _waitingForPartners.add(incoming);
    }

    // Handle this call eventually ending
    late Stream<void> handleEvents;
    handleEvents = incoming.events.map((event) async {
      if (event is StasisEnd) {
        // Channel hung up. What we need to do now depends on its state.
        final state = _activeCalls.remove(incoming);
        switch (state) {
          case null:
          // This can happen if a channel has been removed because its partner
          // hung up. We don't need to do anything in this case.
          case WaitingForPartner():
            // Remove from waiting list.
            _waitingForPartners.remove(incoming);
          case ConnectedCall():
            // Hang up on the other side too.
            for (final other in [state.first, state.second]) {
              if (other != incoming) {
                _activeCalls.remove(other);
                await other.hangUp();
              }
            }
            await state.bridge.destroy();
        }

        _stream.remove(handleEvents);
      }
    });
    _stream.add(handleEvents);
  }
}

sealed class CallState {}

final class WaitingForPartner implements CallState {
  const WaitingForPartner();
}

/// An established connection between two participants.
final class ConnectedCall implements CallState {
  final LiveChannel first;
  final LiveChannel second;
  LiveBridge bridge;

  ConnectedCall(this.first, this.second, this.bridge);
}
