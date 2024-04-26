// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../definitions/channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      id: json['id'] as String,
      protocolId: json['protocol_id'] as String,
      name: json['name'] as String,
      state: $enumDecode(_$ChannelStateEnumMap, json['state']),
      caller: CallerId.fromJson(json['caller'] as Map<String, dynamic>),
      connected: CallerId.fromJson(json['connected'] as Map<String, dynamic>),
      accountCode: json['accountcode'] as String,
      dialplan: DialplanCEP.fromJson(json['dialplan'] as Map<String, dynamic>),
      creationTime: DateTime.parse(json['creationtime'] as String),
      language: json['language'] as String,
      variables: json['channelvars'] as Map<String, dynamic>?,
      callerRdnis: json['caller_rdnis'] as String?,
    );

const _$ChannelStateEnumMap = {
  ChannelState.down: 'Down',
  ChannelState.reserved: 'Rsrved',
  ChannelState.offHook: 'OffHook',
  ChannelState.dialing: 'Dialing',
  ChannelState.ring: 'Ring',
  ChannelState.ringing: 'Ringing',
  ChannelState.up: 'Up',
  ChannelState.busy: 'Busy',
  ChannelState.dialingOffhook: 'Dialing Offhook',
  ChannelState.preRing: 'Pre-Ring',
  ChannelState.unknown: 'Unknown',
};

CallerId _$CallerIdFromJson(Map<String, dynamic> json) => CallerId(
      name: json['name'] as String,
      number: json['number'] as String,
    );

DialplanCEP _$DialplanCEPFromJson(Map<String, dynamic> json) => DialplanCEP(
      context: json['context'] as String,
      exten: json['exten'] as String,
      priority: (json['priority'] as num).toInt(),
      appName: json['app_name'] as String,
      appData: json['app_data'] as String,
    );
