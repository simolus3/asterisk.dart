import 'package:json_annotation/json_annotation.dart';

import '../event/source.dart';
import 'common.dart';

part '../generated/definitions/channel.g.dart';

/// The current state of a channel.
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

/// A channel as described by Asterisk.
///
/// For an enhanced object that listens to updates and can be modified with
/// method calls, see [LiveChannel].
///
/// https://docs.asterisk.org/Latest_API/API_Documentation/Asterisk_REST_Interface/Asterisk_REST_Data_Models/#channel
@JsonSerializable()
final class Channel implements EventSource {
  final String id;
  final String protocolId;
  final String name;
  final ChannelState state;

  /// The [CallerId] of the caller for this channel.
  final CallerId caller;
  final CallerId connected;
  @JsonKey(name: 'accountcode')
  final String accountCode;

  /// Position of the channel in the Asterisk dialplan.
  final DialplanCEP dialplan;

  /// The time at which the channel has been created.
  @JsonKey(name: 'creationtime')
  final DateTime creationTime;

  /// Language code for this channel.
  final String language;

  /// Variables associated with this channel in its current context.
  @JsonKey(name: 'channelvars')
  final JsonObject? variables;

  /// The Caller ID RDNIS
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
  /// The name associated with this caller id, or an empty string if unknown.
  final String name;

  /// The number associated with this caller id.
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
