import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/endpoint.g.dart';

enum EndpointState {
  unknown,
  offline,
  online,
}

/// An endpoint as described by Asterisk.
///
/// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Asterisk_REST_Data_Models/#endpoint
@JsonSerializable()
class Endpoint implements EventSource {
  final String technology;
  final String resource;
  final EndpointState state;
  final List<String> channelIds;

  Endpoint({
    required this.technology,
    required this.resource,
    required this.state,
    required this.channelIds,
  });

  factory Endpoint.fromJson(JsonObject json) => _$EndpointFromJson(json);

  @override
  String toString() {
    return 'Endpoint($technology/$resource, state: $state, channels: $channelIds)';
  }

  @override
  EventSourceDescription get description =>
      EventSourceDescription(kind: 'endpoint', id: '$technology/$resource');
}
