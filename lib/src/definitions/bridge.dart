import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/bridge.g.dart';

enum BridgeType {
  mixing,
  holding,
}

@JsonSerializable()
final class Bridge implements EventSource {
  final String id;
  final String technology;
  final BridgeType bridgeType;
  final String bridgeClass;
  final String creator;
  final String name;
  final List<String> channels;
  @JsonKey(name: 'creationtime')
  final DateTime creationTime;

  Bridge({
    required this.id,
    required this.technology,
    required this.bridgeType,
    required this.bridgeClass,
    required this.creator,
    required this.name,
    required this.channels,
    required this.creationTime,
  });

  factory Bridge.fromJson(JsonObject json) => _$BridgeFromJson(json);

  @override
  EventSourceDescription get description =>
      EventSourceDescription(kind: 'bridge', id: id);
}
