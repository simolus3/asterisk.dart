// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
      name: json['name'] as String,
      channelIds: (json['channel_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bridgeIds: (json['bridge_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      endpointIds: (json['endpoint_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deviceNames: (json['device_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      eventsAllowed: (json['events_allowed'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      eventsDisallowed: (json['events_disallowed'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
