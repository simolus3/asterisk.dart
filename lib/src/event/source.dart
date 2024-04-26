abstract class EventSource {
  EventSourceDescription get description;
}

final class EventSourceDescription {
  final String kind;
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
