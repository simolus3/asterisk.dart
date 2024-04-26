// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/endpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Endpoint _$EndpointFromJson(Map<String, dynamic> json) => Endpoint(
      technology: json['technology'] as String,
      resource: json['resource'] as String,
      state: $enumDecode(_$EndpointStateEnumMap, json['state']),
      channelIds: (json['channel_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

const _$EndpointStateEnumMap = {
  EndpointState.unknown: 'unknown',
  EndpointState.offline: 'offline',
  EndpointState.online: 'online',
};
