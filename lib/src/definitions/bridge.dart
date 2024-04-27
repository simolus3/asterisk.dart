import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/bridge.g.dart';

/// The type of bridge technology.
enum BridgeType {
  mixing,
  holding,
}

/// A bridge as described by Asterisk.
///
/// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Asterisk_REST_Data_Models/#bridge
@JsonSerializable()
final class Bridge implements EventSource {
  /// A unique id for this bridge.
  final String id;

  /// Name of the current bridging technology.
  final String technology;

  /// The [BridgeType] of this bridge.
  final BridgeType bridgeType;

  /// Bridging class.
  final String bridgeClass;

  /// Entity that created the bridge.
  final String creator;

  /// Name the creator gave this bridge.
  final String name;

  /// All channels involved in this bridge.
  final List<String> channels;

  /// The time this bridge has been created.
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
