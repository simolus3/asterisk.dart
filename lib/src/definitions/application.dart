import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part '../generated/definitions/application.g.dart';

@JsonSerializable()
class Application {
  final String name;
  final List<String> channelIds;
  final List<String> bridgeIds;
  final List<String> endpointIds;
  final List<String> deviceNames;
  final List<JsonObject> eventsAllowed;
  final List<JsonObject> eventsDisallowed;

  Application({
    required this.name,
    required this.channelIds,
    required this.bridgeIds,
    required this.endpointIds,
    required this.deviceNames,
    required this.eventsAllowed,
    required this.eventsDisallowed,
  });

  factory Application.fromJson(JsonObject json) => _$ApplicationFromJson(json);
}
