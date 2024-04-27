import 'package:json_annotation/json_annotation.dart';

import 'channel.dart';
import 'common.dart';
import 'endpoint.dart';
import 'playback.dart';
import 'recordings.dart';

part '../generated/definitions/ws_message.g.dart';

sealed class Message {
  final String type;
  final String asteriskId;

  Message({required this.type, required this.asteriskId});

  factory Message.fromJson(JsonObject json) {
    final type = json['type'];
    return switch (type) {
      'ChannelDestroyed' => ChannelDestroyed.fromJson(json),
      'ChannelDtmfReceived' => ChannelDtmfReceived.fromJson(json),
      'ChannelStateChange' => ChannelStateChange.fromJson(json),
      'ChannelTakingFinished' => ChannelTalkingFinished.fromJson(json),
      'ChannelTakingStarted' => ChannelTalkingStarted.fromJson(json),
      'EndpointStateChange' => EndpointStateChange.fromJson(json),
      'MissingParams' => MissingParams.fromJson(json),
      'RecordingFailed' => RecordingFailed.fromJson(json),
      'RecordingFinished' => RecordingFinished.fromJson(json),
      'RecordingStarted' => RecordingStarted.fromJson(json),
      'PlaybackContinuing' => PlaybackContinuing.fromJson(json),
      'PlaybackFinished' => PlaybackFinished.fromJson(json),
      'PlaybackStarted' => PlaybackStarted.fromJson(json),
      'StasisEnd' => StasisEnd.fromJson(json),
      'StasisStart' => StasisStart.fromJson(json),
      _ => UnknownMessage(json: json),
    };
  }
}

sealed class Event extends Message {
  final String application;
  final DateTime timestamp;

  Event({
    required super.type,
    required super.asteriskId,
    required this.application,
    required this.timestamp,
  });
}

abstract interface class HasChannel {
  Channel get channel;
}

final class UnknownMessage extends Message {
  final JsonObject json;

  UnknownMessage({required this.json})
      : super(
          type: json['type'] as String,
          asteriskId: json['asterisk_id'] as String,
        );

  @override
  String toString() {
    return 'Unknown Message: $json';
  }
}

@JsonSerializable()
final class MissingParams extends Message {
  final List<String> params;

  MissingParams({
    required super.type,
    required super.asteriskId,
    required this.params,
  });

  factory MissingParams.fromJson(JsonObject json) =>
      _$MissingParamsFromJson(json);
}

@JsonSerializable()
class ChannelDestroyed extends Event implements HasChannel {
  final int cause;
  final String causeTxt;
  @override
  final Channel channel;

  ChannelDestroyed(
      {required this.cause,
      required this.causeTxt,
      required this.channel,
      required super.type,
      required super.asteriskId,
      required super.application,
      required super.timestamp});

  factory ChannelDestroyed.fromJson(JsonObject json) =>
      _$ChannelDestroyedFromJson(json);
}

@JsonSerializable()
class ChannelDtmfReceived extends Event implements HasChannel {
  @override
  final Channel channel;

  final String digit;

  @JsonKey(name: 'duration_ms', fromJson: _durationFromMillis)
  final Duration duration;

  ChannelDtmfReceived({
    required this.channel,
    required this.duration,
    required this.digit,
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
  });

  factory ChannelDtmfReceived.fromJson(JsonObject json) =>
      _$ChannelDtmfReceivedFromJson(json);

  static Duration _durationFromMillis(int millis) {
    return Duration(milliseconds: millis);
  }
}

@JsonSerializable()
class ChannelStateChange extends Event implements HasChannel {
  @override
  final Channel channel;

  ChannelStateChange({
    required this.channel,
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
  });

  factory ChannelStateChange.fromJson(JsonObject json) =>
      _$ChannelStateChangeFromJson(json);
}

@JsonSerializable()
class ChannelTalkingFinished extends Event implements HasChannel {
  @override
  final Channel channel;
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  final Duration duration;

  ChannelTalkingFinished({
    required this.channel,
    required this.duration,
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
  });

  factory ChannelTalkingFinished.fromJson(JsonObject json) =>
      _$ChannelTalkingFinishedFromJson(json);

  static Duration _durationFromMillis(int millis) {
    return Duration(milliseconds: millis);
  }

  static int _millisFromDuration(Duration duration) {
    return duration.inMilliseconds;
  }
}

@JsonSerializable()
class ChannelTalkingStarted extends Event implements HasChannel {
  @override
  final Channel channel;

  ChannelTalkingStarted({
    required this.channel,
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
  });

  factory ChannelTalkingStarted.fromJson(JsonObject json) =>
      _$ChannelTalkingStartedFromJson(json);
}

@JsonSerializable()
final class EndpointStateChange extends Event {
  final Endpoint endpoint;

  EndpointStateChange({
    required this.endpoint,
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
  });

  factory EndpointStateChange.fromJson(JsonObject json) =>
      _$EndpointStateChangeFromJson(json);
}

abstract interface class HasPlayback {
  Playback get playback;
}

@JsonSerializable()
class PlaybackContinuing extends Event implements HasPlayback {
  @override
  final Playback playback;

  PlaybackContinuing({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required this.playback,
  });

  factory PlaybackContinuing.fromJson(JsonObject json) =>
      _$PlaybackContinuingFromJson(json);
}

@JsonSerializable()
class PlaybackFinished extends Event implements HasPlayback {
  @override
  final Playback playback;

  PlaybackFinished({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required this.playback,
  });

  factory PlaybackFinished.fromJson(JsonObject json) =>
      _$PlaybackFinishedFromJson(json);
}

@JsonSerializable()
class PlaybackStarted extends Event implements HasPlayback {
  @override
  final Playback playback;

  PlaybackStarted({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required this.playback,
  });

  factory PlaybackStarted.fromJson(JsonObject json) =>
      _$PlaybackStartedFromJson(json);
}

sealed class RecordingEvent extends Event {
  final Recording recording;

  RecordingEvent({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required this.recording,
  });
}

@JsonSerializable()
final class RecordingFailed extends RecordingEvent {
  RecordingFailed({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required super.recording,
  });

  factory RecordingFailed.fromJson(JsonObject json) =>
      _$RecordingFailedFromJson(json);
}

@JsonSerializable()
final class RecordingFinished extends RecordingEvent {
  RecordingFinished({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required super.recording,
  });

  factory RecordingFinished.fromJson(JsonObject json) =>
      _$RecordingFinishedFromJson(json);
}

@JsonSerializable()
final class RecordingStarted extends RecordingEvent {
  RecordingStarted({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required super.recording,
  });

  factory RecordingStarted.fromJson(JsonObject json) =>
      _$RecordingStartedFromJson(json);
}

@JsonSerializable()
class StasisEnd extends Event implements HasChannel {
  @override
  final Channel channel;

  StasisEnd(
      {required super.type,
      required super.asteriskId,
      required super.application,
      required super.timestamp,
      required this.channel});

  factory StasisEnd.fromJson(JsonObject json) => _$StasisEndFromJson(json);
}

@JsonSerializable()
final class StasisStart extends Event {
  final List<String> args;
  final Channel channel;
  final Channel? replaceChannel;

  StasisStart({
    required super.type,
    required super.asteriskId,
    required super.application,
    required super.timestamp,
    required this.args,
    required this.channel,
    required this.replaceChannel,
  });

  factory StasisStart.fromJson(JsonObject json) => _$StasisStartFromJson(json);
}
