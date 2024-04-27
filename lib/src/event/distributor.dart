@internal
library;

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../asterisk.dart';
import '../definitions/common.dart';
import '../definitions/ws_message.dart';
import 'source.dart';

final class AsteriskEvents {
  static final Logger _logger = Logger('AsteriskEvents');

  final AsteriskClient _asterisk;
  StreamSubscription? _channelSubscription;

  final Map<EventSourceDescription, List<MultiStreamController<Event>>>
      _sourceListeners = {};
  final List<MultiStreamController<Event>> _globalListeners = [];
  Future<void>? _subscriptionChange;

  List<EventSourceDescription> _pendingSubscriptions = [];
  List<EventSourceDescription> _pendingUnsubscriptions = [];

  AsteriskEvents(this._asterisk) {
    _channelSubscription = _asterisk.channel.stream.listen((event) {
      _logger.finest(() => 'Incoming: $event');

      final message =
          Message.fromJson(json.decode(event as String) as JsonObject);
      if (message is Event) {
        _dispatchEvent(message);
      } else {
        _logger.fine('Saw non-event message: $message');
      }
    });
  }

  /// Schedules REST calls to change the subscriptions this app is interested
  /// in.
  void _scheduleSubscriptionChange() {
    _subscriptionChange ??= Future.delayed(Duration.zero).then((_) async {
      final added = _pendingSubscriptions;
      final removed = _pendingUnsubscriptions;

      _pendingSubscriptions = [];
      _pendingUnsubscriptions = [];
      _subscriptionChange = null;

      _logger.fine('Changing subscriptions: Added $added, removed $removed');
      if (added.isNotEmpty) {
        await _asterisk.api.subscribe(_asterisk.applicationName,
            added.map((e) => '${e.kind}:${e.id}').join(','));
      }
      if (removed.isNotEmpty) {
        await _asterisk.api.unsubscribe(_asterisk.applicationName,
            added.map((e) => '${e.kind}:${e.id}').join(','));
      }
    });
  }

  /// Marks that [description] now has a listener and needs to be subscribed to.
  void _trackPendingSubscription(EventSourceDescription description) {
    _pendingUnsubscriptions.remove(description);
    if (!_pendingSubscriptions.contains(description)) {
      _pendingSubscriptions.add(description);
      _scheduleSubscriptionChange();
    }
  }

  /// Marks [description] as no longer having any listeners, meaning that we'll
  /// unsubscribe from it.
  void _trackPendingUnsubscription(EventSourceDescription description) {
    _pendingSubscriptions.remove(description);
    if (!_pendingUnsubscriptions.contains(description)) {
      _pendingUnsubscriptions.add(description);
      _scheduleSubscriptionChange();
    }
  }

  void _dispatchEvent(Event event) {
    for (final source in event.involvedSources) {
      final List<MultiStreamController<Event>> listeners;

      switch (source) {
        case null:
          listeners = _globalListeners;
        case EventSourceDescription():
          final subscribers = _sourceListeners[source];
          if (subscribers != null) {
            listeners = subscribers;
          } else {
            continue;
          }
      }

      for (final listener in listeners) {
        listener.add(event);
      }
    }
  }

  void _subscribeTo(EventSourceDescription? source,
      MultiStreamController<Event> listener, bool needsSubscription) {
    switch (source) {
      case null:
        _globalListeners.add(listener);
      case EventSourceDescription():
        final listeners = _sourceListeners.putIfAbsent(source, () => []);
        if (listeners.isEmpty && needsSubscription) {
          _trackPendingSubscription(source);
        }

        listeners.add(listener);
    }
  }

  void _unsubscribeFrom(EventSourceDescription? source,
      MultiStreamController<Event> listener, bool needsSubscription) {
    switch (source) {
      case null:
        _globalListeners.remove(listener);
      case EventSourceDescription():
        final listeners = _sourceListeners[source]!;
        listeners.remove(listener);
        if (listeners.isEmpty && needsSubscription) {
          _trackPendingUnsubscription(source);
        }
    }
  }

  Stream<Event> _sourceStream(
      EventSourceDescription? source, bool needsSubscription) {
    return Stream.multi((newListener) {
      _subscribeTo(source, newListener, needsSubscription);
      newListener.onCancel =
          () => _unsubscribeFrom(source, newListener, needsSubscription);
    });
  }

  Stream<Event> get globalEvents => _sourceStream(null, false);

  /// Listens for events from the given [source].
  ///
  /// [needsSubscription] should be set to `true` for sources that an
  /// application is not subscribed to by default.
  Stream<Event> listenFor({
    required EventSource source,
    bool needsSubscription = false,
  }) =>
      _sourceStream(source.description, needsSubscription);

  Future<void> close() async {
    await _channelSubscription?.cancel();
  }
}

extension on Event {
  Iterable<EventSourceDescription?> get involvedSources {
    switch (this) {
      case HasChannel(:final channel):
        return [channel.description];
      case HasPlayback(:final playback):
        return [playback.description];
      case RecordingEvent(:final recording):
        return [recording.description];
      case EndpointStateChange(:final endpoint):
        return [endpoint.description];
      case StasisStart():
        return const [null];
    }
  }
}
