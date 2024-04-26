import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/channel.g.dart';

@JsonEnum(fieldRename: FieldRename.pascal)
enum ChannelState {
  down,
  @JsonValue('Rsrved')
  reserved,
  offHook,
  dialing,
  ring,
  ringing,
  up,
  busy,
  @JsonValue('Dialing Offhook')
  dialingOffhook,
  @JsonValue('Pre-Ring')
  preRing,
  unknown,
}

@JsonSerializable()
final class Channel implements EventSource {
  final String id;
  final String protocolId;
  final String name;
  final ChannelState state;
  final CallerId caller;
  final CallerId connected;
  @JsonKey(name: 'accountcode')
  final String accountCode;
  final DialplanCEP dialplan;
  @JsonKey(name: 'creationtime')
  final DateTime creationTime;
  final String language;
  @JsonKey(name: 'channelvars')
  final JsonObject? variables;
  @JsonKey(name: 'caller_rdnis')
  final String? callerRdnis;

  Channel({
    required this.id,
    required this.protocolId,
    required this.name,
    required this.state,
    required this.caller,
    required this.connected,
    required this.accountCode,
    required this.dialplan,
    required this.creationTime,
    required this.language,
    required this.variables,
    required this.callerRdnis,
  });

  factory Channel.fromJson(JsonObject json) => _$ChannelFromJson(json);

  @override
  EventSourceDescription get description =>
      EventSourceDescription(kind: 'channel', id: id);

  @override
  String toString() {
    return 'Channel $id';
  }
}

@JsonSerializable()
class CallerId {
  final String name;
  final String number;

  CallerId({required this.name, required this.number});

  factory CallerId.fromJson(JsonObject json) => _$CallerIdFromJson(json);

  @override
  String toString() {
    return 'CallerId(name: $name, number: $number)';
  }
}

@JsonSerializable()
class DialplanCEP {
  final String context;
  final String exten;
  final int priority;
  final String appName;
  final String appData;

  DialplanCEP({
    required this.context,
    required this.exten,
    required this.priority,
    required this.appName,
    required this.appData,
  });

  factory DialplanCEP.fromJson(JsonObject json) => _$DialplanCEPFromJson(json);
}
