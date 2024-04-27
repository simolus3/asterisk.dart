import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part '../generated/definitions/application.g.dart';

/// An application as described by Asterisk.
///
/// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Asterisk_REST_Data_Models/#application
@JsonSerializable()
class Application {
  /// The name of this application.
  final String name;

  /// All channels this application is subscribed to.
  final List<String> channelIds;

  /// All bridges this application is subscribed to.
  final List<String> bridgeIds;

  /// All endpoints this application is subscribed to.
  final List<String> endpointIds;

  /// All device names this application is subscribed to.
  final List<String> deviceNames;

  /// An explicit list of event types sent to the application.
  final List<JsonObject> eventsAllowed;

  /// An explicit list of event types not send to the application.
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
