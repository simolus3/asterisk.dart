/// An Asterisk entity emitting events we can subscribe to.
abstract class EventSource {
  /// An identifier for this event source.
  EventSourceDescription get description;
}

final class EventSourceDescription {
  /// The kind of the [EventSource], e.g. `endpoint` or `channel`.
  final String kind;

  /// An id of the [EventSource], so that the pair of [kind] and [id] uniquely
  /// identify the source.
  final String id;

  EventSourceDescription({required this.kind, required this.id});

  @override
  int get hashCode => Object.hash(EventSourceDescription, kind, id);

  @override
  bool operator ==(Object other) {
    return other is EventSourceDescription &&
        other.kind == kind &&
        other.id == id;
  }

  @override
  String toString() {
    return '$kind:$id';
  }
}
