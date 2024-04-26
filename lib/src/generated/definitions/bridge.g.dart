// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/bridge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bridge _$BridgeFromJson(Map<String, dynamic> json) => Bridge(
      id: json['id'] as String,
      technology: json['technology'] as String,
      bridgeType: $enumDecode(_$BridgeTypeEnumMap, json['bridge_type']),
      bridgeClass: json['bridge_class'] as String,
      creator: json['creator'] as String,
      name: json['name'] as String,
      channels:
          (json['channels'] as List<dynamic>).map((e) => e as String).toList(),
      creationTime: DateTime.parse(json['creationtime'] as String),
    );

const _$BridgeTypeEnumMap = {
  BridgeType.mixing: 'mixing',
  BridgeType.holding: 'holding',
};
